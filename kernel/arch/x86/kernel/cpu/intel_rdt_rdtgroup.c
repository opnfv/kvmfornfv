/*
 * User interface for Resource Alloction in Resource Director Technology(RDT)
 *
 * Copyright (C) 2016 Intel Corporation
 *
 * Author: Fenghua Yu <fenghua.yu@intel.com>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * More information about RDT be found in the Intel (R) x86 Architecture
 * Software Developer Manual.
 */

#define pr_fmt(fmt)	KBUILD_MODNAME ": " fmt

#include <linux/fs.h>
#include <linux/sysfs.h>
#include <linux/kernfs.h>
#include <linux/seq_file.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/cpu.h>

#include <uapi/linux/magic.h>

#include <asm/intel_rdt.h>
#include <asm/intel_rdt_common.h>

DEFINE_STATIC_KEY_FALSE(rdt_enable_key);
struct kernfs_root *rdt_root;
struct rdtgroup rdtgroup_default;
LIST_HEAD(rdt_all_groups);

/* Kernel fs node for "info" directory under root */
static struct kernfs_node *kn_info;

/*
 * Trivial allocator for CLOSIDs. Since h/w only supports a small number,
 * we can keep a bitmap of free CLOSIDs in a single integer.
 *
 * Using a global CLOSID across all resources has some advantages and
 * some drawbacks:
 * + We can simply set "current->closid" to assign a task to a resource
 *   group.
 * + Context switch code can avoid extra memory references deciding which
 *   CLOSID to load into the PQR_ASSOC MSR
 * - We give up some options in configuring resource groups across multi-socket
 *   systems.
 * - Our choices on how to configure each resource become progressively more
 *   limited as the number of resources grows.
 */
static int closid_free_map;

static void closid_init(void)
{
	struct rdt_resource *r;
	int rdt_min_closid = 32;

	/* Compute rdt_min_closid across all resources */
	for_each_enabled_rdt_resource(r)
		rdt_min_closid = min(rdt_min_closid, r->num_closid);

	closid_free_map = BIT_MASK(rdt_min_closid) - 1;

	/* CLOSID 0 is always reserved for the default group */
	closid_free_map &= ~1;
}

int closid_alloc(void)
{
	int closid = ffs(closid_free_map);

	if (closid == 0)
		return -ENOSPC;
	closid--;
	closid_free_map &= ~(1 << closid);

	return closid;
}

static void closid_free(int closid)
{
	closid_free_map |= 1 << closid;
}

/* set uid and gid of rdtgroup dirs and files to that of the creator */
static int rdtgroup_kn_set_ugid(struct kernfs_node *kn)
{
	struct iattr iattr = { .ia_valid = ATTR_UID | ATTR_GID,
				.ia_uid = current_fsuid(),
				.ia_gid = current_fsgid(), };

	if (uid_eq(iattr.ia_uid, GLOBAL_ROOT_UID) &&
	    gid_eq(iattr.ia_gid, GLOBAL_ROOT_GID))
		return 0;

	return kernfs_setattr(kn, &iattr);
}

static int rdtgroup_add_file(struct kernfs_node *parent_kn, struct rftype *rft)
{
	struct kernfs_node *kn;
	int ret;

	kn = __kernfs_create_file(parent_kn, rft->name, rft->mode,
				  0, rft->kf_ops, rft, NULL, NULL);
	if (IS_ERR(kn))
		return PTR_ERR(kn);

	ret = rdtgroup_kn_set_ugid(kn);
	if (ret) {
		kernfs_remove(kn);
		return ret;
	}

	return 0;
}

static int rdtgroup_add_files(struct kernfs_node *kn, struct rftype *rfts,
			      int len)
{
	struct rftype *rft;
	int ret;

	lockdep_assert_held(&rdtgroup_mutex);

	for (rft = rfts; rft < rfts + len; rft++) {
		ret = rdtgroup_add_file(kn, rft);
		if (ret)
			goto error;
	}

	return 0;
error:
	pr_warn("Failed to add %s, err=%d\n", rft->name, ret);
	while (--rft >= rfts)
		kernfs_remove_by_name(kn, rft->name);
	return ret;
}

static int rdtgroup_seqfile_show(struct seq_file *m, void *arg)
{
	struct kernfs_open_file *of = m->private;
	struct rftype *rft = of->kn->priv;

	if (rft->seq_show)
		return rft->seq_show(of, m, arg);
	return 0;
}

static ssize_t rdtgroup_file_write(struct kernfs_open_file *of, char *buf,
				   size_t nbytes, loff_t off)
{
	struct rftype *rft = of->kn->priv;

	if (rft->write)
		return rft->write(of, buf, nbytes, off);

	return -EINVAL;
}

static struct kernfs_ops rdtgroup_kf_single_ops = {
	.atomic_write_len	= PAGE_SIZE,
	.write			= rdtgroup_file_write,
	.seq_show		= rdtgroup_seqfile_show,
};

static int rdt_num_closids_show(struct kernfs_open_file *of,
				struct seq_file *seq, void *v)
{
	struct rdt_resource *r = of->kn->parent->priv;

	seq_printf(seq, "%d\n", r->num_closid);

	return 0;
}

static int rdt_cbm_mask_show(struct kernfs_open_file *of,
			     struct seq_file *seq, void *v)
{
	struct rdt_resource *r = of->kn->parent->priv;

	seq_printf(seq, "%x\n", r->max_cbm);

	return 0;
}

/* rdtgroup information files for one cache resource. */
static struct rftype res_info_files[] = {
	{
		.name		= "num_closids",
		.mode		= 0444,
		.kf_ops		= &rdtgroup_kf_single_ops,
		.seq_show	= rdt_num_closids_show,
	},
	{
		.name		= "cbm_mask",
		.mode		= 0444,
		.kf_ops		= &rdtgroup_kf_single_ops,
		.seq_show	= rdt_cbm_mask_show,
	},
};

static int rdtgroup_create_info_dir(struct kernfs_node *parent_kn)
{
	struct kernfs_node *kn_subdir;
	struct rdt_resource *r;
	int ret;

	/* create the directory */
	kn_info = kernfs_create_dir(parent_kn, "info", parent_kn->mode, NULL);
	if (IS_ERR(kn_info))
		return PTR_ERR(kn_info);
	kernfs_get(kn_info);

	for_each_enabled_rdt_resource(r) {
		kn_subdir = kernfs_create_dir(kn_info, r->name,
					      kn_info->mode, r);
		if (IS_ERR(kn_subdir)) {
			ret = PTR_ERR(kn_subdir);
			goto out_destroy;
		}
		kernfs_get(kn_subdir);
		ret = rdtgroup_kn_set_ugid(kn_subdir);
		if (ret)
			goto out_destroy;
		ret = rdtgroup_add_files(kn_subdir, res_info_files,
					 ARRAY_SIZE(res_info_files));
		if (ret)
			goto out_destroy;
		kernfs_activate(kn_subdir);
	}

	/*
	 * This extra ref will be put in kernfs_remove() and guarantees
	 * that @rdtgrp->kn is always accessible.
	 */
	kernfs_get(kn_info);

	ret = rdtgroup_kn_set_ugid(kn_info);
	if (ret)
		goto out_destroy;

	kernfs_activate(kn_info);

	return 0;

out_destroy:
	kernfs_remove(kn_info);
	return ret;
}

static void l3_qos_cfg_update(void *arg)
{
	bool *enable = arg;

	wrmsrl(IA32_L3_QOS_CFG, *enable ? L3_QOS_CDP_ENABLE : 0ULL);
}

static int set_l3_qos_cfg(struct rdt_resource *r, bool enable)
{
	cpumask_var_t cpu_mask;
	struct rdt_domain *d;
	int cpu;

	if (!zalloc_cpumask_var(&cpu_mask, GFP_KERNEL))
		return -ENOMEM;

	list_for_each_entry(d, &r->domains, list) {
		/* Pick one CPU from each domain instance to update MSR */
		cpumask_set_cpu(cpumask_any(&d->cpu_mask), cpu_mask);
	}
	cpu = get_cpu();
	/* Update QOS_CFG MSR on this cpu if it's in cpu_mask. */
	if (cpumask_test_cpu(cpu, cpu_mask))
		l3_qos_cfg_update(&enable);
	/* Update QOS_CFG MSR on all other cpus in cpu_mask. */
	smp_call_function_many(cpu_mask, l3_qos_cfg_update, &enable, 1);
	put_cpu();

	free_cpumask_var(cpu_mask);

	return 0;
}

static int cdp_enable(void)
{
	struct rdt_resource *r_l3data = &rdt_resources_all[RDT_RESOURCE_L3DATA];
	struct rdt_resource *r_l3code = &rdt_resources_all[RDT_RESOURCE_L3CODE];
	struct rdt_resource *r_l3 = &rdt_resources_all[RDT_RESOURCE_L3];
	int ret;

	if (!r_l3->capable || !r_l3data->capable || !r_l3code->capable)
		return -EINVAL;

	ret = set_l3_qos_cfg(r_l3, true);
	if (!ret) {
		r_l3->enabled = false;
		r_l3data->enabled = true;
		r_l3code->enabled = true;
	}
	return ret;
}

static void cdp_disable(void)
{
	struct rdt_resource *r = &rdt_resources_all[RDT_RESOURCE_L3];

	r->enabled = r->capable;

	if (rdt_resources_all[RDT_RESOURCE_L3DATA].enabled) {
		rdt_resources_all[RDT_RESOURCE_L3DATA].enabled = false;
		rdt_resources_all[RDT_RESOURCE_L3CODE].enabled = false;
		set_l3_qos_cfg(r, false);
	}
}

static int parse_rdtgroupfs_options(char *data)
{
	char *token, *o = data;
	int ret = 0;

	while ((token = strsep(&o, ",")) != NULL) {
		if (!*token)
			return -EINVAL;

		if (!strcmp(token, "cdp"))
			ret = cdp_enable();
	}

	return ret;
}

/*
 * We don't allow rdtgroup directories to be created anywhere
 * except the root directory. Thus when looking for the rdtgroup
 * structure for a kernfs node we are either looking at a directory,
 * in which case the rdtgroup structure is pointed at by the "priv"
 * field, otherwise we have a file, and need only look to the parent
 * to find the rdtgroup.
 */
static struct rdtgroup *kernfs_to_rdtgroup(struct kernfs_node *kn)
{
	if (kernfs_type(kn) == KERNFS_DIR)
		return kn->priv;
	else
		return kn->parent->priv;
}

struct rdtgroup *rdtgroup_kn_lock_live(struct kernfs_node *kn)
{
	struct rdtgroup *rdtgrp = kernfs_to_rdtgroup(kn);

	atomic_inc(&rdtgrp->waitcount);
	kernfs_break_active_protection(kn);

	mutex_lock(&rdtgroup_mutex);

	/* Was this group deleted while we waited? */
	if (rdtgrp->flags & RDT_DELETED)
		return NULL;

	return rdtgrp;
}

void rdtgroup_kn_unlock(struct kernfs_node *kn)
{
	struct rdtgroup *rdtgrp = kernfs_to_rdtgroup(kn);

	mutex_unlock(&rdtgroup_mutex);

	if (atomic_dec_and_test(&rdtgrp->waitcount) &&
	    (rdtgrp->flags & RDT_DELETED)) {
		kernfs_unbreak_active_protection(kn);
		kernfs_put(kn);
		kfree(rdtgrp);
	} else {
		kernfs_unbreak_active_protection(kn);
	}
}

static struct dentry *rdt_mount(struct file_system_type *fs_type,
				int flags, const char *unused_dev_name,
				void *data)
{
	struct dentry *dentry;
	int ret;

	mutex_lock(&rdtgroup_mutex);
	/*
	 * resctrl file system can only be mounted once.
	 */
	if (static_branch_unlikely(&rdt_enable_key)) {
		dentry = ERR_PTR(-EBUSY);
		goto out;
	}

	ret = parse_rdtgroupfs_options(data);
	if (ret) {
		dentry = ERR_PTR(ret);
		goto out_cdp;
	}

	closid_init();

	ret = rdtgroup_create_info_dir(rdtgroup_default.kn);
	if (ret)
		goto out_cdp;

	dentry = kernfs_mount(fs_type, flags, rdt_root,
			      RDTGROUP_SUPER_MAGIC, NULL);
	if (IS_ERR(dentry))
		goto out_cdp;

	static_branch_enable(&rdt_enable_key);
	goto out;

out_cdp:
	cdp_disable();
out:
	mutex_unlock(&rdtgroup_mutex);

	return dentry;
}

static int reset_all_cbms(struct rdt_resource *r)
{
	struct msr_param msr_param;
	cpumask_var_t cpu_mask;
	struct rdt_domain *d;
	int i, cpu;

	if (!zalloc_cpumask_var(&cpu_mask, GFP_KERNEL))
		return -ENOMEM;

	msr_param.res = r;
	msr_param.low = 0;
	msr_param.high = r->num_closid;

	/*
	 * Disable resource control for this resource by setting all
	 * CBMs in all domains to the maximum mask value. Pick one CPU
	 * from each domain to update the MSRs below.
	 */
	list_for_each_entry(d, &r->domains, list) {
		cpumask_set_cpu(cpumask_any(&d->cpu_mask), cpu_mask);

		for (i = 0; i < r->num_closid; i++)
			d->cbm[i] = r->max_cbm;
	}
	cpu = get_cpu();
	/* Update CBM on this cpu if it's in cpu_mask. */
	if (cpumask_test_cpu(cpu, cpu_mask))
		rdt_cbm_update(&msr_param);
	/* Update CBM on all other cpus in cpu_mask. */
	smp_call_function_many(cpu_mask, rdt_cbm_update, &msr_param, 1);
	put_cpu();

	free_cpumask_var(cpu_mask);

	return 0;
}

/*
 * MSR_IA32_PQR_ASSOC is scoped per logical CPU, so all updates
 * are always in thread context.
 */
static void rdt_reset_pqr_assoc_closid(void *v)
{
	struct intel_pqr_state *state = this_cpu_ptr(&pqr_state);

	state->closid = 0;
	wrmsr(MSR_IA32_PQR_ASSOC, state->rmid, 0);
}

/*
 * Forcibly remove all of subdirectories under root.
 */
static void rmdir_all_sub(void)
{
	struct rdtgroup *rdtgrp, *tmp;

	get_cpu();
	/* Reset PQR_ASSOC MSR on this cpu. */
	rdt_reset_pqr_assoc_closid(NULL);
	/* Reset PQR_ASSOC MSR on the rest of cpus. */
	smp_call_function_many(cpu_online_mask, rdt_reset_pqr_assoc_closid,
			       NULL, 1);
	put_cpu();
	list_for_each_entry_safe(rdtgrp, tmp, &rdt_all_groups, rdtgroup_list) {
		/* Remove each rdtgroup other than root */
		if (rdtgrp == &rdtgroup_default)
			continue;
		kernfs_remove(rdtgrp->kn);
		list_del(&rdtgrp->rdtgroup_list);
		kfree(rdtgrp);
	}
	kernfs_remove(kn_info);
}

static void rdt_kill_sb(struct super_block *sb)
{
	struct rdt_resource *r;

	mutex_lock(&rdtgroup_mutex);

	/*Put everything back to default values. */
	for_each_enabled_rdt_resource(r)
		reset_all_cbms(r);
	cdp_disable();
	rmdir_all_sub();
	static_branch_disable(&rdt_enable_key);
	kernfs_kill_sb(sb);
	mutex_unlock(&rdtgroup_mutex);
}

static struct file_system_type rdt_fs_type = {
	.name    = "resctrl",
	.mount   = rdt_mount,
	.kill_sb = rdt_kill_sb,
};

static int rdtgroup_mkdir(struct kernfs_node *parent_kn, const char *name,
			  umode_t mode)
{
	struct rdtgroup *parent, *rdtgrp;
	struct kernfs_node *kn;
	int ret, closid;

	/* Only allow mkdir in the root directory */
	if (parent_kn != rdtgroup_default.kn)
		return -EPERM;

	/* Do not accept '\n' to avoid unparsable situation. */
	if (strchr(name, '\n'))
		return -EINVAL;

	parent = rdtgroup_kn_lock_live(parent_kn);
	if (!parent) {
		ret = -ENODEV;
		goto out_unlock;
	}

	ret = closid_alloc();
	if (ret < 0)
		goto out_unlock;
	closid = ret;

	/* allocate the rdtgroup. */
	rdtgrp = kzalloc(sizeof(*rdtgrp), GFP_KERNEL);
	if (!rdtgrp) {
		ret = -ENOSPC;
		goto out_closid_free;
	}
	rdtgrp->closid = closid;
	list_add(&rdtgrp->rdtgroup_list, &rdt_all_groups);

	/* kernfs creates the directory for rdtgrp */
	kn = kernfs_create_dir(parent->kn, name, mode, rdtgrp);
	if (IS_ERR(kn)) {
		ret = PTR_ERR(kn);
		goto out_cancel_ref;
	}
	rdtgrp->kn = kn;

	/*
	 * kernfs_remove() will drop the reference count on "kn" which
	 * will free it. But we still need it to stick around for the
	 * rdtgroup_kn_unlock(kn} call below. Take one extra reference
	 * here, which will be dropped inside rdtgroup_kn_unlock().
	 */
	kernfs_get(kn);

	ret = rdtgroup_kn_set_ugid(kn);
	if (ret)
		goto out_destroy;

	kernfs_activate(kn);

	ret = 0;
	goto out_unlock;

out_destroy:
	kernfs_remove(rdtgrp->kn);
out_cancel_ref:
	list_del(&rdtgrp->rdtgroup_list);
	kfree(rdtgrp);
out_closid_free:
	closid_free(closid);
out_unlock:
	rdtgroup_kn_unlock(parent_kn);
	return ret;
}

static int rdtgroup_rmdir(struct kernfs_node *kn)
{
	struct rdtgroup *rdtgrp;
	int ret = 0;

	rdtgrp = rdtgroup_kn_lock_live(kn);
	if (!rdtgrp) {
		rdtgroup_kn_unlock(kn);
		return -ENOENT;
	}

	rdtgrp->flags = RDT_DELETED;
	closid_free(rdtgrp->closid);
	list_del(&rdtgrp->rdtgroup_list);

	/*
	 * one extra hold on this, will drop when we kfree(rdtgrp)
	 * in rdtgroup_kn_unlock()
	 */
	kernfs_get(kn);
	kernfs_remove(rdtgrp->kn);

	rdtgroup_kn_unlock(kn);

	return ret;
}

static struct kernfs_syscall_ops rdtgroup_kf_syscall_ops = {
	.mkdir	= rdtgroup_mkdir,
	.rmdir	= rdtgroup_rmdir,
};

static int __init rdtgroup_setup_root(void)
{
	rdt_root = kernfs_create_root(&rdtgroup_kf_syscall_ops,
				      KERNFS_ROOT_CREATE_DEACTIVATED,
				      &rdtgroup_default);
	if (IS_ERR(rdt_root))
		return PTR_ERR(rdt_root);

	mutex_lock(&rdtgroup_mutex);

	rdtgroup_default.closid = 0;
	list_add(&rdtgroup_default.rdtgroup_list, &rdt_all_groups);

	rdtgroup_default.kn = rdt_root->kn;
	kernfs_activate(rdtgroup_default.kn);

	mutex_unlock(&rdtgroup_mutex);

	return 0;
}

/*
 * rdtgroup_init - rdtgroup initialization
 *
 * Setup resctrl file system including set up root, create mount point,
 * register rdtgroup filesystem, and initialize files under root directory.
 *
 * Return: 0 on success or -errno
 */
int __init rdtgroup_init(void)
{
	int ret = 0;

	ret = rdtgroup_setup_root();
	if (ret)
		return ret;

	ret = sysfs_create_mount_point(fs_kobj, "resctrl");
	if (ret)
		goto cleanup_root;

	ret = register_filesystem(&rdt_fs_type);
	if (ret)
		goto cleanup_mountpoint;

	return 0;

cleanup_mountpoint:
	sysfs_remove_mount_point(fs_kobj, "resctrl");
cleanup_root:
	kernfs_destroy_root(rdt_root);

	return ret;
}
