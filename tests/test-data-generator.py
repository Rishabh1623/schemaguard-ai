#!/usr/bin/env python3
"""
Test Data Generator for SchemaGuard AI
Generates realistic test data for various scenarios
"""

import json
import random
from datetime import datetime, timedelta
from typing import List, Dict, Any

# Sample data for realistic generation
USER_IDS = [f"user-{i:04d}" for i in range(1, 101)]
EVENT_TYPES = ["user_action", "system_event", "api_call", "data_update"]
ACTIONS = ["click", "scroll", "submit", "view", "download", "upload", "delete", "edit"]
TARGETS = ["button", "link", "form", "page", "image", "video", "document", "profile"]
LOCATIONS = ["New York", "London", "Tokyo", "Paris", "Sydney", "Mumbai", "Toronto", "Berlin"]
DEVICES = ["desktop", "mobile", "tablet"]
BROWSERS = ["Chrome", "Firefox", "Safari", "Edge"]

def generate_timestamp(days_ago: int = 0, hours_ago: int = 0) -> int:
    """Generate Unix timestamp in milliseconds"""
    dt = datetime.now() - timedelta(days=days_ago, hours=hours_ago)
    return int(dt.timestamp() * 1000)

def generate_baseline_event() -> Dict[str, Any]:
    """Generate event matching the baseline contract"""
    return {
        "id": f"evt-{random.randint(10000, 99999)}",
        "timestamp": generate_timestamp(hours_ago=random.randint(0, 24)),
        "event_type": random.choice(EVENT_TYPES),
        "user_id": random.choice(USER_IDS),
        "data": {
            "action": random.choice(ACTIONS),
            "target": random.choice(TARGETS)
        }
    }

def generate_additive_change_event() -> Dict[str, Any]:
    """Generate event with new fields (additive change)"""
    event = generate_baseline_event()
    # Add new fields
    event["user_location"] = random.choice(LOCATIONS)
    event["device_type"] = random.choice(DEVICES)
    event["browser"] = random.choice(BROWSERS)
    return event

def generate_breaking_change_event() -> Dict[str, Any]:
    """Generate event with type changes (breaking change)"""
    return {
        "id": f"evt-{random.randint(10000, 99999)}",
        "timestamp": datetime.now().isoformat(),  # String instead of number
        "event_type": random.choice(EVENT_TYPES),
        "user_id": random.randint(1000, 9999),  # Number instead of string
        "data": {
            "action": random.choice(ACTIONS),
            "target": random.choice(TARGETS)
        }
    }

def generate_missing_required_field_event() -> Dict[str, Any]:
    """Generate event missing required fields"""
    return {
        "id": f"evt-{random.randint(10000, 99999)}",
        # Missing timestamp (required field)
        "event_type": random.choice(EVENT_TYPES),
        "data": {
            "action": random.choice(ACTIONS)
        }
    }

def generate_nested_structure_change() -> Dict[str, Any]:
    """Generate event with nested structure changes"""
    event = generate_baseline_event()
    event["data"]["metadata"] = {
        "session_id": f"sess-{random.randint(1000, 9999)}",
        "duration": random.randint(10, 3600),
        "success": random.choice([True, False])
    }
    return event

def save_test_file(filename: str, data: Any):
    """Save test data to JSON file"""
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"✅ Created: {filename}")

def generate_batch_events(count: int, event_type: str = "baseline") -> List[Dict]:
    """Generate batch of events"""
    generators = {
        "baseline": generate_baseline_event,
        "additive": generate_additive_change_event,
        "breaking": generate_breaking_change_event,
        "missing": generate_missing_required_field_event,
        "nested": generate_nested_structure_change
    }
    
    generator = generators.get(event_type, generate_baseline_event)
    return [generator() for _ in range(count)]

def main():
    """Generate all test data files"""
    print("🚀 Generating test data for SchemaGuard AI...\n")
    
    # 1. Baseline data (matches contract)
    print("📝 Generating baseline test data...")
    save_test_file("test-baseline-single.json", generate_baseline_event())
    save_test_file("test-baseline-batch-10.json", generate_batch_events(10, "baseline"))
    save_test_file("test-baseline-batch-100.json", generate_batch_events(100, "baseline"))
    
    # 2. Additive changes (new fields)
    print("\n📝 Generating additive change test data...")
    save_test_file("test-additive-single.json", generate_additive_change_event())
    save_test_file("test-additive-batch-10.json", generate_batch_events(10, "additive"))
    
    # 3. Breaking changes (type changes)
    print("\n📝 Generating breaking change test data...")
    save_test_file("test-breaking-single.json", generate_breaking_change_event())
    save_test_file("test-breaking-batch-10.json", generate_batch_events(10, "breaking"))
    
    # 4. Missing required fields
    print("\n📝 Generating missing field test data...")
    save_test_file("test-missing-field-single.json", generate_missing_required_field_event())
    
    # 5. Nested structure changes
    print("\n📝 Generating nested structure test data...")
    save_test_file("test-nested-single.json", generate_nested_structure_change())
    save_test_file("test-nested-batch-10.json", generate_batch_events(10, "nested"))
    
    # 6. Mixed scenarios
    print("\n📝 Generating mixed scenario test data...")
    mixed_batch = (
        generate_batch_events(50, "baseline") +
        generate_batch_events(30, "additive") +
        generate_batch_events(15, "nested") +
        generate_batch_events(5, "breaking")
    )
    random.shuffle(mixed_batch)
    save_test_file("test-mixed-batch-100.json", mixed_batch)
    
    # 7. Time-series data (for realistic testing)
    print("\n📝 Generating time-series test data...")
    timeseries = []
    for hour in range(24):
        for _ in range(random.randint(5, 15)):
            event = generate_baseline_event()
            event["timestamp"] = generate_timestamp(hours_ago=23-hour)
            timeseries.append(event)
    save_test_file("test-timeseries-24h.json", timeseries)
    
    print("\n✅ All test data generated successfully!")
    print("\n📊 Summary:")
    print("  - Baseline: 3 files (single, 10, 100 events)")
    print("  - Additive: 2 files (single, 10 events)")
    print("  - Breaking: 2 files (single, 10 events)")
    print("  - Missing: 1 file (single event)")
    print("  - Nested: 2 files (single, 10 events)")
    print("  - Mixed: 1 file (100 events)")
    print("  - Time-series: 1 file (24 hours)")
    print("\n🎯 Ready for testing!")

if __name__ == "__main__":
    main()
