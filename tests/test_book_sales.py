#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
出版畅销书销售模拟测试
模拟从写书到销售3年的完整流程
包含书籍对博客文章访问量的加成效果
"""

import random
import math

# 测试参数
WRITE_DAYS = 200           # 写作天数
LITERATURE_VALUE = 90      # 文学能力值（90分）
SALES_DURATION = 36        # 销售周期（36个月=3年）
PEAK_MIN = 100000          # 峰值最低月收入
PEAK_MAX = 200000          # 峰值最高月收入
PUBLISH_REWARD = 50000     # 出版一次性收益

def calculate_write_quality(write_days, literature_value):
    """计算写作质量"""
    day_factor = min(max(write_days / 336.0, 0.5), 1.0)
    lit_factor = literature_value / 100.0
    return day_factor * lit_factor

def calculate_monthly_income(write_quality, sales_month):
    """计算月销售收入"""
    quality_peak = PEAK_MIN + (PEAK_MAX - PEAK_MIN) * write_quality
    
    income = 0.0
    
    if sales_month < 12:
        # 0-12月：上升期（二次增长）
        growth_rate = (sales_month + 1) / 12.0
        income = quality_peak * growth_rate * growth_rate
    elif sales_month < 18:
        # 12-18月：峰值期（波动±10%）
        peak_factor = 1.0 + random.uniform(-0.1, 0.1)
        income = quality_peak * peak_factor
    else:
        # 18-36月：下降期（指数衰减）
        decline_rate = 1.0 - ((sales_month - 18) / 18.0)
        decline_rate = max(decline_rate, 0.0)
        income = quality_peak * pow(decline_rate, 1.5)
        income *= (0.8 + random.random() * 0.4)  # 波动±20%
    
    return int(max(income, 0))

def calculate_book_boost_ratio(sales_month):
    """计算书籍对博客文章的加成比例"""
    if sales_month >= 36:
        return 0.0
    
    if sales_month <= 18:
        # 0-18月：线性上升 0% -> 100%
        return sales_month / 18.0
    else:
        # 18-36月：线性下降 100% -> 0%
        return (36.0 - sales_month) / 18.0

def get_sales_status(sales_month):
    """获取销售状态描述"""
    if sales_month >= 36:
        return "已停售"
    elif sales_month < 12:
        return "热销上升期"
    elif sales_month < 18:
        return "销售高峰期"
    else:
        return "销售衰退期"

def simulate_book_publishing():
    """模拟完整出版销售流程"""
    
    print("=" * 60)
    print("📚 出版畅销书销售模拟测试")
    print("=" * 60)
    
    # 参数显示
    print(f"\n【测试参数】")
    print(f"  写作天数：{WRITE_DAYS} 天")
    print(f"  文学能力值：{LITERATURE_VALUE} 分")
    print(f"  销售周期：{SALES_DURATION} 个月（3年）")
    
    # 阶段1：写作
    print(f"\n【阶段1：写作阶段】")
    print(f"  持续写作 {WRITE_DAYS} 天...")
    
    write_quality = calculate_write_quality(WRITE_DAYS, LITERATURE_VALUE)
    print(f"  写作质量：{write_quality:.2f} (满分1.0)")
    
    # 阶段2：出版
    print(f"\n【阶段2：出版阶段】")
    print(f"  编辑修改：5 天")
    print(f"  出版社审核：7 天")
    print(f"  总耗时：{WRITE_DAYS + 5 + 7} 天")
    
    # 出版收益
    publish_reward = int(PUBLISH_REWARD * (WRITE_DAYS / 168.0))
    print(f"\n【出版一次性收益】")
    print(f"  基础收益：{PUBLISH_REWARD} 元")
    print(f"  写作天数加成：×{WRITE_DAYS/168.0:.2f}")
    print(f"  实际收益：{publish_reward} 元")
    print(f"  声望奖励：1000 点")
    
    # 阶段3：销售（3年）
    print(f"\n【阶段3：销售阶段（3年）】")
    print("-" * 60)
    
    total_sales_income = 0
    monthly_records = []
    
    print(f"  {'月份':^6} | {'销售状态':^10} | {'月收入':^12} | {'累计收入':^14} | {'博客加成':^10}")
    print(f"  {'-'*6}-|-{'-'*10}-|-{'-'*12}-|-{'-'*14}-|-{'-'*10}")
    
    for month in range(1, SALES_DURATION + 1):
        income = calculate_monthly_income(write_quality, month)
        total_sales_income += income
        status = get_sales_status(month)
        boost_ratio = calculate_book_boost_ratio(month)
        
        record = {
            "month": month,
            "income": income,
            "total": total_sales_income,
            "status": status,
            "boost_ratio": boost_ratio
        }
        monthly_records.append(record)
        
        # 每6个月或重要节点输出
        if month in [1, 3, 6, 12, 18, 24, 30, 36]:
            boost_percent = int(boost_ratio * 100)
            print(f"  第{month:2d}月 | {status:10s} | {income:>10,} 元 | {total_sales_income:>12,} 元 | +{boost_percent:>3}%")
    
    # 关键节点详情
    print(f"\n【关键节点详情】")
    key_months = [6, 12, 15, 18, 24, 30, 36]
    for m in key_months:
        r = monthly_records[m-1]
        print(f"  第{m:2d}月：收入 {r['income']:>10,} 元 | 累计 {r['total']:>12,} 元 | {r['status']}")
    
    # 总收益汇总
    print(f"\n" + "=" * 60)
    print(f"【收益汇总】")
    print(f"=" * 60)
    print(f"  📖 书籍信息：")
    print(f"     写作天数：{WRITE_DAYS} 天")
    print(f"     文学能力：{LITERATURE_VALUE} 分")
    print(f"     写作质量：{write_quality:.2f}")
    print(f"\n  💰 收益明细：")
    print(f"     出版一次性收益：{publish_reward:>12,} 元")
    print(f"     3年销售总收入：{total_sales_income:>12,} 元")
    print(f"     ─────────────────────────")
    print(f"     总收益：{publish_reward + total_sales_income:>15,} 元")
    
    # 博客加成影响
    print(f"\n  📝 博客文章访问量加成：")
    print(f"     加成曲线：0-18月上升，18-36月下降")
    print(f"     峰值加成：+100%（第18月）")
    print(f"     示例：原本100访问量 → 峰值时200访问量")
    
    # 计算博客加成带来的额外收益（假设每月发布10篇文章，每篇基础访问量100）
    base_monthly_views = 10 * 100  # 1000
    total_extra_views = 0
    for r in monthly_records:
        extra = int(base_monthly_views * r['boost_ratio'])
        total_extra_views += extra
    print(f"     3年累计额外访问量：约 {total_extra_views:,} 次")
    
    # 峰值分析
    peak_income = max(r['income'] for r in monthly_records)
    peak_month = next(r['month'] for r in monthly_records if r['income'] == peak_income)
    print(f"\n  📈 峰值分析：")
    print(f"     峰值月收入：{peak_income:>12,} 元（第{peak_month}月）")
    print(f"     平均月收入：{total_sales_income // SALES_DURATION:>12,} 元")
    
    # 阶段收入分析
    phase1_income = sum(r['income'] for r in monthly_records[:12])   # 上升期
    phase2_income = sum(r['income'] for r in monthly_records[12:18]) # 峰值期
    phase3_income = sum(r['income'] for r in monthly_records[18:])   # 衰退期
    
    print(f"\n  📊 阶段分析：")
    print(f"     上升期(0-12月)：{phase1_income:>12,} 元 ({phase1_income*100//total_sales_income:>3}%)")
    print(f"     峰值期(12-18月)：{phase2_income:>12,} 元 ({phase2_income*100//total_sales_income:>3}%)")
    print(f"     衰退期(18-36月)：{phase3_income:>12,} 元 ({phase3_income*100//total_sales_income:>3}%)")
    
    print(f"\n" + "=" * 60)
    
    return {
        "write_days": WRITE_DAYS,
        "literature_value": LITERATURE_VALUE,
        "write_quality": write_quality,
        "publish_reward": publish_reward,
        "total_sales_income": total_sales_income,
        "total_income": publish_reward + total_sales_income,
        "peak_income": peak_income,
        "peak_month": peak_month,
    }

def compare_different_literature_values():
    """比较不同文学值的收益差异"""
    print(f"\n\n{'='*60}")
    print(f"📚 不同文学能力值的收益对比")
    print(f"{'='*60}")
    
    literature_values = [60, 70, 80, 90, 100]
    write_days = 200
    
    print(f"\n  写作天数：{write_days} 天\n")
    print(f"  {'文学值':^8} | {'写作质量':^8} | {'出版收益':^12} | {'销售收益':^14} | {'总收益':^14}")
    print(f"  {'-'*8}-|-{'-'*8}-|-{'-'*12}-|-{'-'*14}-|-{'-'*14}")
    
    for lit_val in literature_values:
        write_quality = calculate_write_quality(write_days, lit_val)
        publish_reward = int(PUBLISH_REWARD * (write_days / 168.0))
        
        # 计算3年销售
        total_sales = 0
        for month in range(1, 37):
            total_sales += calculate_monthly_income(write_quality, month)
        
        total_income = publish_reward + total_sales
        
        print(f"  {lit_val:^8} | {write_quality:^8.2f} | {publish_reward:>10,} 元 | {total_sales:>12,} 元 | {total_income:>12,} 元")

if __name__ == "__main__":
    # 设置随机种子（可重现）
    random.seed(42)
    
    # 运行主模拟
    result = simulate_book_publishing()
    
    # 比较不同文学值
    compare_different_literature_values()
    
    print(f"\n测试完成！")