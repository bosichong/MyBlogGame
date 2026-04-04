#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
文学技能文章解锁测试系统 - 独立验证脚本
用于验证配置文件的正确性，无需Godot运行时
"""

import json
import re
import os

# 测试配置
TEST_CONFIG = {
    "literature_levels": [20, 40, 60, 80, 100],
    "novel_count_for_ip": 50,
}

# 文章解锁映射
ARTICLE_UNLOCK_MAP = {
    20: "散文随笔",
    40: "文学周刊",
    60: "爆款网文",
    80: "小说连载(付费)",
    100: "出版畅销书",
}

# 测试结果
test_results = []

def add_result(category, name, passed, detail=""):
    test_results.append({
        "category": category,
        "name": name,
        "passed": passed,
        "detail": detail
    })
    status = "✓ 通过" if passed else "✗ 失败"
    print(f"  [{status}] {category} - {name}")
    if detail:
        print(f"         {detail}")

def read_file(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        return None

def test_article_unlock_conditions():
    """测试文章解锁条件是否存在"""
    print("\n【测试1：文章解锁条件验证】")
    print("-" * 40)
    
    task_config = read_file("scripts/task_system/TaskConfig.gd")
    if not task_config:
        add_result("文件检查", "TaskConfig.gd 存在", False, "文件未找到")
        return
    
    add_result("文件检查", "TaskConfig.gd 存在", True)
    
    # 检查条件定义
    for level in TEST_CONFIG["literature_levels"]:
        cond_id = f"literature_value_ge_{level}"
        pattern = rf'"{cond_id}":\s*\{{[^}}]*"value":\s*{level}[^}}]*\}}'
        found = bool(re.search(pattern, task_config))
        article = ARTICLE_UNLOCK_MAP.get(level, "未知")
        add_result("条件定义", f"{cond_id} ({article})", found)

def test_article_unlock_tasks():
    """测试文章解锁任务是否存在"""
    print("\n【测试2：文章解锁任务验证】")
    print("-" * 40)
    
    task_config = read_file("scripts/task_system/TaskConfig.gd")
    if not task_config:
        return
    
    for level in TEST_CONFIG["literature_levels"]:
        task_id = f"literature_post_unlock_{level}"
        article = ARTICLE_UNLOCK_MAP.get(level, "未知")
        
        # 检查任务ID
        task_pattern = rf'"id":\s*"{task_id}"'
        task_found = bool(re.search(task_pattern, task_config))
        
        # 检查动作（使用字符串搜索，避免正则转义问题）
        action_found = f'"post_type": "{article}"' in task_config
        
        add_result("任务定义", f"{task_id}", task_found and action_found, 
                   f"文章: {article}")

def test_ip_authorization_config():
    """测试IP授权配置"""
    print("\n【测试3：IP授权配置验证】")
    print("-" * 40)
    
    task_config = read_file("scripts/task_system/TaskConfig.gd")
    
    # 检查IP授权任务
    ip_task_found = bool(re.search(r'"id":\s*"ip_authorization_unlock"', task_config or ""))
    add_result("任务定义", "ip_authorization_unlock", ip_task_found)
    
    # 检查小说连载条件
    novel_cond_found = bool(re.search(r'"novel_serial_ge_50"', task_config or ""))
    add_result("条件定义", "novel_serial_ge_50", novel_cond_found)
    
    # 检查ActionType
    action_found = bool(re.search(r'TRIGGER_IP_AUTH', task_config or ""))
    add_result("动作类型", "TRIGGER_IP_AUTH", action_found)

def test_book_publish_config():
    """测试出版畅销书配置"""
    print("\n【测试4：出版畅销书配置验证】")
    print("-" * 40)
    
    # 检查数据文件
    book_publish = read_file("data/book_publish.gd")
    add_result("数据文件", "book_publish.gd 存在", book_publish is not None)
    
    publishers = read_file("data/publishers.gd")
    add_result("数据文件", "publishers.gd 存在", publishers is not None)
    
    ip_companies = read_file("data/ip_companies.gd")
    add_result("数据文件", "ip_companies.gd 存在", ip_companies is not None)
    
    # 检查时间参数
    if book_publish:
        min_days_found = "168" in book_publish  # 游戏内半年
        add_result("时间参数", "min_write_days = 168", min_days_found, "游戏内半年")
    
    # 检查出版商数量
    if publishers:
        publisher_count = publishers.count('"name":')
        add_result("出版商数量", f"{publisher_count}家出版商", publisher_count >= 5)

def test_blog_categories():
    """测试文章类型配置"""
    print("\n【测试5：文章类型配置验证】")
    print("-" * 40)
    
    blog_categories = read_file("data/blog_categories.gd")
    if not blog_categories:
        add_result("文件检查", "blog_categories.gd 存在", False)
        return
    
    add_result("文件检查", "blog_categories.gd 存在", True)
    
    # 检查文章类型
    for level, article in ARTICLE_UNLOCK_MAP.items():
        article_found = f'"name": "{article}"' in blog_categories
        add_result("文章类型", f"{article}", article_found)
    
    # 检查任务中的文章类型（转义特殊字符）
    for level, article in ARTICLE_UNLOCK_MAP.items():
        escaped_article = article.replace("(", "\\(").replace(")", "\\)")
        action_pattern = rf'"post_type":\s*"{escaped_article}"'
        action_found = bool(re.search(action_pattern, blog_categories))
    
    # 检查IP授权文章
    ip_article_found = '"name": "IP授权"' in blog_categories
    add_result("文章类型", "IP授权", ip_article_found)

def test_task_manager():
    """测试任务管理器"""
    print("\n【测试6：任务管理器验证】")
    print("-" * 40)
    
    task_manager = read_file("scripts/task_system/TaskManager.gd")
    if not task_manager:
        add_result("文件检查", "TaskManager.gd 存在", False)
        return
    
    add_result("文件检查", "TaskManager.gd 存在", True)
    
    # 检查动作处理函数
    actions = [
        "_action_start_book_write",
        "_action_book_progress",
        "_action_book_phase_change",
        "_action_trigger_ip_auth",
        "_action_ip_monthly_income",
    ]
    
    for action in actions:
        found = action in task_manager
        add_result("动作函数", action, found)

def count_passed():
    return sum(1 for r in test_results if r["passed"])

def count_failed():
    return sum(1 for r in test_results if not r["passed"])

def print_report():
    print("\n" + "=" * 60)
    print("【测试报告】")
    print("=" * 60)
    print(f"总测试数: {len(test_results)}")
    print(f"通过: {count_passed()}")
    print(f"失败: {count_failed()}")
    print(f"通过率: {count_passed() * 100 / max(len(test_results), 1):.1f}%")
    
    if count_failed() > 0:
        print("\n【失败测试详情】")
        for r in test_results:
            if not r["passed"]:
                print(f"  - [{r['category']}] {r['name']}")
                if r.get("detail"):
                    print(f"    {r['detail']}")
    
    print("=" * 60)
    return count_failed() == 0

def main():
    print("\n" + "*" * 60)
    print("*  文学技能文章解锁测试系统 - 配置验证")
    print("*" * 60)
    
    # 切换到项目目录
    os.chdir("/home/bosi/mygodot/MyBlogGame")
    
    # 运行所有测试
    test_article_unlock_conditions()
    test_article_unlock_tasks()
    test_ip_authorization_config()
    test_book_publish_config()
    test_blog_categories()
    test_task_manager()
    
    # 输出报告
    all_passed = print_report()
    
    print("\n" + "*" * 60)
    if all_passed:
        print("*  ✓ 所有配置验证通过！")
    else:
        print(f"*  ✗ 有 {count_failed()} 个配置验证失败！")
    print("*" * 60)
    
    return 0 if all_passed else 1

if __name__ == "__main__":
    exit(main())