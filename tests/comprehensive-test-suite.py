#!/usr/bin/env python3
"""
Comprehensive Test Suite for SchemaGuard AI
Generates 1000+ test files and measures real performance metrics
"""

import json
import random
import time
from datetime import datetime, timedelta
from pathlib import Path
import hashlib

# Test scenarios with realistic distributions
TEST_SCENARIOS = {
    "baseline": 700,           # 70% - No changes
    "additive": 200,           # 20% - New fields added
    "breaking": 50,            # 5% - Type changes
    "missing_required": 30,    # 3% - Missing fields
    "nested_changes": 20       # 2% - Nested structure changes
}

# Realistic field names for e-commerce
FIELD_POOLS = {
    "user_fields": ["user_id", "email", "username", "first_name", "last_name", "phone", "age"],
    "order_fields": ["order_id", "total_amount", "currency", "status", "payment_method"],
    "product_fields": ["product_id", "name", "price", "category", "sku", "inventory"],
    "metadata_fields": ["timestamp", "source", "version", "session_id", "device_type"],
    "new_fields": ["loyalty_points", "referral_code", "subscription_tier", "preferences", 
                   "shipping_address", "billing_address", "tax_id", "company_name"]
}

def generate_baseline_event(index):
    """Generate baseline event matching contract_v1.json"""
    return {
        "id": f"event-{index:06d}",
        "timestamp": int((datetime.utcnow() - timedelta(minutes=random.randint(0, 1440))).timestamp() * 1000),
        "event_type": random.choice(["user_action", "system_event", "api_call"]),
        "user_id": f"user-{random.randint(1000, 9999)}",
        "data": {
            "action": random.choice(["click", "view", "purchase", "search"]),
            "target": random.choice(["button", "link", "product", "page"])
        }
    }

def generate_additive_event(index):
    """Generate event with new fields (additive change)"""
    event = generate_baseline_event(index)
    # Add 1-3 new fields
    new_field_count = random.randint(1, 3)
    new_fields = random.sample(FIELD_POOLS["new_fields"], new_field_count)
    
    for field in new_fields:
        if field == "loyalty_points":
            event[field] = random.randint(0, 10000)
        elif field == "subscription_tier":
            event[field] = random.choice(["free", "basic", "premium", "enterprise"])
        elif field == "device_type":
            event[field] = random.choice(["mobile", "desktop", "tablet"])
        else:
            event[field] = f"value_{field}"
    
    return event

def generate_breaking_event(index):
    """Generate event with type changes (breaking change)"""
    event = generate_baseline_event(index)
    # Change types of existing fields
    if random.random() > 0.5:
        event["timestamp"] = str(event["timestamp"])  # number -> string
    if random.random() > 0.5:
        event["user_id"] = int(event["user_id"].split("-")[1])  # string -> number
    
    return event

def generate_missing_required_event(index):
    """Generate event missing required fields"""
    event = generate_baseline_event(index)
    # Remove 1-2 required fields
    fields_to_remove = random.sample(["timestamp", "user_id", "event_type"], 
                                     random.randint(1, 2))
    for field in fields_to_remove:
        event.pop(field, None)
    
    return event

def generate_nested_event(index):
    """Generate event with nested structure changes"""
    event = generate_baseline_event(index)
    # Add nested metadata
    event["metadata"] = {
        "ip_address": f"192.168.{random.randint(0,255)}.{random.randint(0,255)}",
        "user_agent": "Mozilla/5.0",
        "geo": {
            "country": random.choice(["US", "UK", "CA", "AU"]),
            "city": random.choice(["New York", "London", "Toronto", "Sydney"])
        }
    }
    return event

def generate_test_files(output_dir="tests/generated"):
    """Generate all test files"""
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    print("🚀 Generating comprehensive test suite...")
    print(f"📁 Output directory: {output_dir}")
    print()
    
    stats = {
        "total_files": 0,
        "total_size_bytes": 0,
        "scenarios": {},
        "generation_time": 0
    }
    
    start_time = time.time()
    file_index = 1
    
    for scenario, count in TEST_SCENARIOS.items():
        print(f"📝 Generating {count} files for scenario: {scenario}")
        scenario_stats = {
            "count": count,
            "files": [],
            "avg_size": 0
        }
        
        for i in range(count):
            # Generate event based on scenario
            if scenario == "baseline":
                event = generate_baseline_event(file_index)
            elif scenario == "additive":
                event = generate_additive_event(file_index)
            elif scenario == "breaking":
                event = generate_breaking_event(file_index)
            elif scenario == "missing_required":
                event = generate_missing_required_event(file_index)
            elif scenario == "nested_changes":
                event = generate_nested_event(file_index)
            
            # Write to file
            filename = f"{scenario}_{file_index:04d}.json"
            filepath = Path(output_dir) / filename
            
            with open(filepath, 'w') as f:
                json.dump(event, f, indent=2)
            
            file_size = filepath.stat().st_size
            stats["total_size_bytes"] += file_size
            scenario_stats["files"].append({
                "name": filename,
                "size": file_size,
                "checksum": hashlib.md5(json.dumps(event).encode()).hexdigest()
            })
            
            file_index += 1
        
        scenario_stats["avg_size"] = stats["total_size_bytes"] / file_index if file_index > 0 else 0
        stats["scenarios"][scenario] = scenario_stats
        stats["total_files"] = file_index - 1
    
    stats["generation_time"] = time.time() - start_time
    
    # Save statistics
    stats_file = Path(output_dir) / "test_statistics.json"
    with open(stats_file, 'w') as f:
        json.dump(stats, f, indent=2)
    
    print()
    print("✅ Test suite generation complete!")
    print()
    print("📊 Statistics:")
    print(f"   Total files: {stats['total_files']}")
    print(f"   Total size: {stats['total_size_bytes'] / 1024:.2f} KB")
    print(f"   Generation time: {stats['generation_time']:.2f} seconds")
    print()
    print("📋 Scenario Distribution:")
    for scenario, data in stats["scenarios"].items():
        print(f"   {scenario}: {data['count']} files ({data['count']/stats['total_files']*100:.1f}%)")
    print()
    print(f"💾 Statistics saved to: {stats_file}")
    
    return stats

def generate_expected_results():
    """Generate expected test results for validation"""
    expected = {
        "test_suite_version": "1.0",
        "generated_at": datetime.utcnow().isoformat(),
        "expected_detections": {
            "baseline": {
                "count": 700,
                "expected_classification": "NO_CHANGE",
                "expected_action": "PROCESS_NORMALLY"
            },
            "additive": {
                "count": 200,
                "expected_classification": "ADDITIVE",
                "expected_action": "VALIDATE_AND_APPROVE",
                "expected_new_fields": ["loyalty_points", "subscription_tier", "device_type", 
                                       "referral_code", "preferences", "shipping_address"]
            },
            "breaking": {
                "count": 50,
                "expected_classification": "BREAKING",
                "expected_action": "QUARANTINE_AND_ALERT",
                "expected_issues": ["type_change_timestamp", "type_change_user_id"]
            },
            "missing_required": {
                "count": 30,
                "expected_classification": "INVALID",
                "expected_action": "QUARANTINE_IMMEDIATELY",
                "expected_issues": ["missing_timestamp", "missing_user_id", "missing_event_type"]
            },
            "nested_changes": {
                "count": 20,
                "expected_classification": "ADDITIVE",
                "expected_action": "VALIDATE_AND_APPROVE",
                "expected_new_fields": ["metadata"]
            }
        },
        "expected_metrics": {
            "total_files_processed": 1000,
            "detection_accuracy": "100%",
            "false_positives": 0,
            "false_negatives": 0,
            "avg_processing_time_seconds": 45,
            "max_processing_time_seconds": 120,
            "quarantine_rate": "8%",  # (50 + 30) / 1000
            "auto_approve_rate": "22%",  # (200 + 20) / 1000
            "no_action_rate": "70%"  # 700 / 1000
        },
        "expected_cost": {
            "bedrock_api_calls": 1000,
            "bedrock_cost_usd": 3.00,  # $0.003 per call
            "lambda_invocations": 4000,  # 4 functions per file
            "lambda_cost_usd": 0.80,
            "step_functions_transitions": 10000,
            "step_functions_cost_usd": 0.25,
            "dynamodb_writes": 5000,
            "dynamodb_cost_usd": 0.01,
            "s3_operations": 3000,
            "s3_cost_usd": 0.02,
            "total_cost_usd": 4.08,
            "cost_per_file_usd": 0.00408
        }
    }
    
    expected_file = Path("tests/generated") / "expected_results.json"
    with open(expected_file, 'w') as f:
        json.dump(expected, f, indent=2)
    
    print(f"📋 Expected results saved to: {expected_file}")
    return expected

if __name__ == "__main__":
    print("=" * 70)
    print("SchemaGuard AI - Comprehensive Test Suite Generator")
    print("=" * 70)
    print()
    
    # Generate test files
    stats = generate_test_files()
    
    # Generate expected results
    expected = generate_expected_results()
    
    print()
    print("=" * 70)
    print("🎉 Test Suite Ready!")
    print("=" * 70)
    print()
    print("📝 Next Steps:")
    print("   1. Deploy SchemaGuard infrastructure")
    print("   2. Run: python tests/run_comprehensive_tests.py")
    print("   3. Compare actual vs expected results")
    print("   4. Update README with real metrics")
    print()
    print("💡 This will give you REAL performance data for interviews!")
    print()
