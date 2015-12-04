#ifndef _ASM_X86_IOMMU_H
#define _ASM_X86_IOMMU_H

extern struct dma_map_ops nommu_dma_ops;
extern int force_iommu, no_iommu;
extern int iommu_detected;
extern int iommu_pass_through;

/* 10 seconds */
#define DMAR_OPERATION_TIMEOUT ((cycles_t) tsc_khz*10*1000)

#ifdef CONFIG_INTEL_IOMMU_DEFAULT_PASSTHROUGH
#define DEFAULT_IOMMU_SETUP CONFIG_INTEL_IOMMU_DEFAULT;
#else
#define DEFAULT_IOMMU_SETUP ( CONFIG_IOMMU_SUPPORT ? "on" : "off" );
#endif

#endif /* _ASM_X86_IOMMU_H */
