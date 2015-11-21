#define _LARGEFILE64_SOURCE
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <limits.h>
#include <time.h>
#include <pthread.h>
#include <sched.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

struct file_header
{
  uint32_t signature;
  uint16_t vmentry_id;
  uint16_t vmexit_id;
};

struct thread_param
{
  int raw_fd;
  int out_fd;
  int pipefd[2];
  int cpu;
};

struct event
{
  uint64_t timestamp;
  uint16_t type;
};

enum rb_type
{
  RINGBUF_TYPE_DATA_TYPE_LEN_MAX = 28,
  RINGBUF_TYPE_PADDING,
  RINGBUF_TYPE_TIME_EXTEND,
  RINGBUF_TYPE_TIME_STAMP
};

struct vmexit_data
{
  uint32_t exit_reason;
  uint64_t guest_rip;
  uint32_t isa;
  uint64_t info1;
  uint64_t info2;
};

struct vmentry_data
{
  uint32_t vcpu_id;
};

#pragma pack(1)

struct trace_data
{
  uint16_t type;
  uint8_t flags;
  uint8_t preempt_count;
  int32_t pid;
  uint16_t migrate_disable;
  uint16_t padding1;
  uint32_t padding2;
  union
  {
    struct vmexit_data vmexit;
    struct vmentry_data vmentry;
  };
};

struct event_entry
{
  uint32_t type_len: 5, time_delta: 27;
  union
  {
    uint32_t array[1];
    struct trace_data trace;
  };
};

#define DATA_SIZE 4080

struct event_page
{
  uint64_t timestamp;
  uint64_t commit;
  union
  {
    uint8_t data[DATA_SIZE];
    struct event_entry event;
  };
};

#define PAGE_SIZE sizeof(struct event_page)

#define TRACE_PATH "/sys/kernel/debug/tracing"
#define TRACE_FILE "trace.bin"
#define TRACE_SIG 0xcce96d01

#define VM_ENTRY "kvm/kvm_entry"
#define VM_EXIT "kvm/kvm_exit"

#ifdef DEBUG
#define dbg_printf(_f_,...) {printf(_f_,##__VA_ARGS__);}
#else
#define dbg_printf(_f_,...)
#endif

static uint16_t vmentry_id;
static uint16_t vmexit_id;

static int stop_tracing;
static int verbose;


static struct event* read_events(int fd, size_t *n)
{
  int i, j;
  ssize_t rd;
  uint32_t len, offset;
  uint64_t event_time, pre_event_time, pre_page_time = 0;
  struct event_page page;
  struct event_entry *e;
  struct event *events = NULL;

  *n = 0;
  for (i = 0; 1; i++)
  {
    if ((rd = read(fd, &page, PAGE_SIZE)) == 0)
      return events;
    else if (rd < 0)
    {
      fprintf(stderr, "Failed to read trace file\n");
      free(events);
      return NULL;
    }
    else if (rd < PAGE_SIZE)
    {
      fprintf(stderr, "Trace file does not have enough data\n");
      free(events);
      return NULL;
    }

    dbg_printf("Page %d:\n", i);
    dbg_printf("  timestamp = %ld\n", page.timestamp);
    dbg_printf("  commit = %ld\n", page.commit);

    if (page.timestamp < pre_page_time)
      fprintf(stderr, "Warning: page time going backwards\n");

    pre_page_time = page.timestamp;

    offset = 0;
    pre_event_time = 0;
    for (j = 0; 1; j++)
    {
      e = (struct event_entry *)(page.data+offset);

      if (e->type_len == 0)
        e = (struct event_entry *)&e->array[1];

      if (pre_event_time)
        event_time = pre_event_time + e->time_delta;
      else
        event_time = page.timestamp;

      if (e->type_len < RINGBUF_TYPE_DATA_TYPE_LEN_MAX)
      {
        len = (e->type_len+1) * sizeof(uint32_t);

        if (e->trace.type == vmexit_id || e->trace.type == vmentry_id)
        {
          if ((events = realloc(events, (*n+1) * sizeof(struct event))) == NULL)
          {
            fprintf(stderr, "Failed to allocate memory\n");
            return NULL;
          }

          events[*n].timestamp = event_time;
          events[*n].type = e->trace.type;

          if (verbose)
          {
            if (e->trace.type == vmexit_id)
            {
              printf("  %ld: VM_EXIT reason: %08x, ", event_time, e->trace.vmexit.exit_reason);
              printf("info1: %016lx, info2: %08lx\n", e->trace.vmexit.info1, e->trace.vmexit.info2);
            }
            else
            {
              printf("  %ld: VM_ENTRY dt: %d, vcpu: %d\n", event_time, e->time_delta, e->trace.vmentry.vcpu_id);
            }
          }

          *n += 1;
        }
        else if (e->trace.type == 0)
          break;
        else
          fprintf(stderr, "UNKNOWN event %d\n", e->trace.type);
      }
      else if (e->type_len == RINGBUF_TYPE_TIME_EXTEND)
      {
        len = 8;
        event_time = pre_event_time + (e->time_delta | (e->array[0]<<28));
        dbg_printf("  entry %d: TIME_EXTEND %ld\n", j, event_time);
      }
      else if (e->type_len == RINGBUF_TYPE_PADDING)
      {
        if (e->time_delta == 0)
          break;

        len = e->array[0] + sizeof(uint32_t);
        dbg_printf("  entry %d: PADDING, len %d @ %ld\n", j, len, event_time);
      }
      else if (e->type_len == RINGBUF_TYPE_TIME_STAMP)
      {
        len = 16;
        dbg_printf("  entry %d: TIME_STAMP @ %ld\n", j, event_time);
      }

      pre_event_time = event_time;

      offset += len;
      if (offset >= DATA_SIZE)
        break;
    }

    dbg_printf("  events in page %d = %d\n", i, j);
  }

  return events;
}

static int parse_trace_file(char *file)
{
  int fd;
  uint16_t pre_event = 0;
  struct event *events;
  size_t num_events, i, j = 0;
  uint64_t d, exit_time = 0, total = 0, max_lat = 0;
  uint64_t pre_time = 0, acc_1ms = 0, max_acc = 0;
  struct file_header header;

  if ((fd = open(file, O_RDONLY|O_LARGEFILE)) < 0)
  {
    perror(file);
    return -1;
  }

  if (read(fd, &header, sizeof(struct file_header)) < 0)
  {
    perror(file);
    return -1;
  }

  if (header.signature != TRACE_SIG)
  {
    fprintf(stderr, "File %s is not a vm-trace file\n", file);
    return -1;
  }

  vmentry_id = header.vmentry_id;
  vmexit_id = header.vmexit_id;

  if ((events = read_events(fd, &num_events)) == NULL)
    return -1;

  printf("Number of VM events = %ld\n", num_events);

  for (i = 0; i < num_events; i++)
  {
    if (events[i].type == vmexit_id)
    {
      exit_time = events[i].timestamp;
    }
    else if (events[i].type == vmentry_id)
    {
      if (exit_time)
      {
        d = events[i].timestamp - exit_time;
        if (d > max_lat)
          max_lat = d;

        total += d;
        acc_1ms += d;
        j++;
      }
    }

    if (events[i].type == pre_event)
      fprintf(stderr, "Warning: repeated events\n");
    pre_event = events[i].type;

    if (pre_time)
    {
      if (events[i].timestamp - pre_time >= 1000000)
      {
        if (acc_1ms > max_acc)
          max_acc = acc_1ms;

        acc_1ms = 0;
        pre_time = events[i].timestamp;
      }
    }
    else
      pre_time = events[i].timestamp;
  }

  free(events);

  printf("Average VM Exit-Entry latency = %ldus\n", total/j/1000);
  printf("Maximum VM Exit-Entry latency = %ldus\n", max_lat/1000);
  printf("Maximum cumulative latency within 1ms = %ldus\n", max_acc/1000);

  close(fd);
  return 0;
}

static int get_event_id(char *event)
{
  char path[PATH_MAX+1];
  int fd;
  ssize_t r;

  sprintf(path, "%s/events/%s/id", TRACE_PATH, event);
  if ((fd = open(path, O_RDONLY)) < 0)
  {
    perror(path);
    return -1;
  }

  if ((r = read(fd, path, PATH_MAX)) < 0)
  {
    close(fd);
    perror(path);
    return -1;
  }

  close(fd);

  path[r+1] = '\0';
  return atoi(path);
}

static int enable_event(char *event, int en)
{
  char path[PATH_MAX+1], *s;
  int fd;

  if (en)
    s = "1";
  else
    s = "0";

  sprintf(path, "%s/events/%s/enable", TRACE_PATH, event);
  if ((fd = open(path, O_WRONLY | O_TRUNC)) < 0)
  {
    perror(path);
    return -1;
  }

  if (write(fd, s, 2) < 0)
  {
    close(fd);
    perror(path);
    return -1;
  }

  close(fd);

  return 0;
}

static int enable_events(int en)
{
  if (enable_event(VM_ENTRY, en) < 0)
    return -1;

  if (enable_event(VM_EXIT, en) < 0)
    return -1;

  return 0;
}

static int setup_tracing(int cpu)
{
  char path[PATH_MAX+1], mask[20];
  int fd, h, l;

  if (cpu > 31)
  {
    l = 0;
    h = 1 << (cpu-32);
  }
  else
  {
    l = 1 << cpu;
    h = 0;
  }

  sprintf(mask, "%X,%X", h, l);

  sprintf(path, "%s/tracing_cpumask", TRACE_PATH);
  if ((fd = open(path, O_WRONLY | O_TRUNC)) < 0)
  {
    perror(path);
    return -1;
  }

  if (write(fd, mask, strlen(mask)) < 0)
  {
    close(fd);
    perror(path);
    return -1;
  }

  close(fd);

  sprintf(path, "%s/trace", TRACE_PATH);
  if ((fd = open(path, O_WRONLY | O_TRUNC)) < 0)
  {
    perror(path);
    return -1;
  }

  if (write(fd, "", 1) < 0)
  {
    close(fd);
    perror(path);
    return -1;
  }

  close(fd);

  if ((vmentry_id = get_event_id(VM_ENTRY)) < 0)
    return -1;

  if ((vmexit_id = get_event_id(VM_EXIT)) < 0)
    return -1;

  if (enable_events(1) < 0)
    return -1;

  return 0;
}

static void disable_tracing(int fd, pthread_t thread)
{
  if (write(fd, "0", 2) < 0)
    perror("disable_tracing");
  close(fd);

  enable_events(0);

  stop_tracing = 1;
  pthread_join(thread, NULL);
}

static void *tracing_thread(void *param)
{
  cpu_set_t mask;
  struct thread_param *p = param;
  ssize_t r;

  CPU_ZERO(&mask);
  CPU_SET(p->cpu, &mask);
  if(pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &mask) != 0)
    fprintf(stderr, "Could not set CPU affinity to CPU #%d\n", p->cpu);

  while (!stop_tracing)
  {
    if ((r = splice(p->raw_fd, NULL, p->pipefd[1], NULL, PAGE_SIZE, SPLICE_F_MOVE|SPLICE_F_NONBLOCK)) < 0)
    {
      if (errno == EAGAIN)
        continue;

      perror("splice1");
      break;
    }
    else if (r == 0)
      continue;

    if (splice(p->pipefd[0], NULL, p->out_fd, NULL, PAGE_SIZE, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) < 0)
    {
      perror("splice2");
      break;
    }
  }

  close(p->raw_fd);
  close(p->pipefd[1]);
  close(p->pipefd[0]);
  close(p->out_fd);

  return NULL;
}

static void usage(char *argv[])
{
  fprintf(stderr, "Usage: %s -p cpu_to_trace -c cpu_to_collect_trace -s duration_in_seconds\n", argv[0]);
  fprintf(stderr, "       %s -f trace_file [-v]\n", argv[0]);
  exit(-1);
}

int main(int argc, char *argv[])
{
  char path[PATH_MAX+1], *file = NULL;
  int cpu = -1, ttime = 0;
  int opt, fd;
  pthread_t thread;
  struct file_header header;
  struct thread_param param;
  struct timespec interval;

  param.cpu = -1;

  while ((opt = getopt(argc, argv, "p:c:s:f:v")) != -1)
  {
    switch (opt)
    {
      case 'p':
        cpu = atoi(optarg);
        break;
      case 'c':
        param.cpu = atoi(optarg);
        break;
      case 's':
        ttime = atoi(optarg);
        break;
      case 'f':
        file = optarg;
        break;
      case 'v':
        verbose = 1;
        break;
      default:
        usage(argv);
    }
  }

  if ((cpu < 0 || param.cpu < 0 || ttime <= 0) && file == NULL)
    usage(argv);

  if (file != NULL)
    return parse_trace_file(file);

  verbose = 0;

  if (setup_tracing(cpu) < 0)
    return -1;

  if ((param.out_fd = open(TRACE_FILE, O_WRONLY|O_CREAT|O_TRUNC|O_LARGEFILE, 0644)) < 0)
  {
    perror(TRACE_FILE);
    return -1;
  }

  header.signature = TRACE_SIG;
  header.vmentry_id = vmentry_id;
  header.vmexit_id = vmexit_id;

  if (write(param.out_fd, &header, sizeof(struct file_header)) < 0)
  {
    perror(TRACE_FILE);
    return -1;
  }

  sprintf(path, "%s/per_cpu/cpu%d/trace_pipe_raw", TRACE_PATH, cpu);
  if ((param.raw_fd = open(path, O_RDONLY)) < 0)
  {
    perror(path);
    return -1;
  }

  if (pipe(param.pipefd) < 0)
  {
    perror("pipe");
    return -1;
  }

  sprintf(path, "%s/tracing_on", TRACE_PATH);
  if ((fd = open(path, O_WRONLY)) < 0)
  {
    perror(path);
    return -1;
  }

  if (pthread_create(&thread, NULL, tracing_thread, &param))
  {
    perror("pthread_create");
    return -1;
  }

  if (write(fd, "1", 2) < 0)
  {
    perror(path);
    disable_tracing(fd, thread);
    return -1;
  }

  printf("Sleeping for %d seconds ...\n", ttime);

  interval.tv_sec = ttime;
  interval.tv_nsec = 0;
  if (clock_nanosleep(CLOCK_MONOTONIC, 0, &interval, NULL))
  {
    perror("clock_nanosleep");
    disable_tracing(fd, thread);
    return -1;
  }

  disable_tracing(fd, thread);

  printf("Processing event file ...\n");

  return parse_trace_file(TRACE_FILE);
}
