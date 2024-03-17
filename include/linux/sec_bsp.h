/*
 * include/linux/sec_bsp.h
 *
 * COPYRIGHT(C) 2014-2017 Samsung Electronics Co., Ltd. All Right Reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#ifndef SEC_BSP_H
#define SEC_BSP_H

#ifdef CONFIG_SEC_BSP
#include <linux/dma-mapping.h>
#include <linux/miscdevice.h>

struct memshare_rd_device {
	char name[256];
	struct miscdevice device;
	unsigned long address;
	/* void *v_address; */
	unsigned long size;
	unsigned int data_ready;
	unsigned long attrs;
};

extern unsigned int is_boot_recovery(void);
extern unsigned int get_boot_stat_time(void);
extern unsigned int get_boot_stat_freq(void);
extern void sec_boot_stat_add(const char *c);
extern void sec_bootstat_add_initcall(const char *s);
extern void sec_suspend_resume_add(const char *c);
extern void sec_bsp_enable_console(void);
extern bool sec_bsp_is_console_enabled(void);

extern unsigned int sec_hw_rev(void);
#else /* CONFIG_SEC_BSP */
#define is_boot_recovery()		(0)
#define get_boot_stat_time()
#define get_boot_stat_freq()
#define sec_boot_stat_add(c)
#define sec_bootstat_add_initcall(s)
#define sec_suspend_resume_add(c)
#define sec_bsp_enable_console()
#define sec_bsp_is_console_enabled()	(0)
#define sec_hw_rev()			(0)
#endif /* CONFIG_SEC_BSP */

extern struct list_head device_init_time_list;

struct device_init_time_entry {
	struct list_head next;
	char *buf;
	unsigned long long duration;
};

#define DEVICE_INIT_TIME_100MS 100000

#define MAX_LENGTH_OF_SYSTEMSERVER_LOG 90
struct systemserver_init_time_entry {
	struct list_head next;
	char buf[MAX_LENGTH_OF_SYSTEMSERVER_LOG];
};

#endif /* SEC_BSP_H */
