#!/usr/bin/env python3
"""
Quick Demo Script for SchemaGuard AI
Generates 10 test files and demonstrates all scenarios in 10 minutes
Perfect for live video demonstrations
"""

import json
import time
from datetime import datetime
from pathlib import Path

def generate_demo_files(output_dir="tests/demo"):
    """Generate 10 carefully chosen demo files"""
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    print("🎬 SchemaGuard AI - Live Demo")
    print("=" * 70)
    print()
    print("📝 Generating 10 demo files (one for each scenario)...")
    print()
    
    demos = []
    
    # Demo 1: Baseline (matches contract perfectly)
    demos.append({
        "filename": "01_baseline_perfect_match.json",
        "description": "✅ Perfect match - No schema changes",
        "expected": "NO_CHANGE → Process normally",
        "data": {
            "id": "demo-001",
            "timestamp": 1704067200000,
            "event_type": "user_action",
            "user_id": "user-1234",
            "data": {
                "action": "purchase",
                "target": "product"
            }
        }
    })
    
    # Demo 2: Additive - Single new field
    demos.append({
        "filename": "02_additive_single_field.json",
        "description": "➕ New field added: payment_method",
        "expected": "ADDITIVE → Validate and approve",
        "data": {
            "id": "demo-002",
            "timestamp": 1704067200000,
            "event_type": "user_action",
            "user_id": "user-5678",
            "payment_method": "credit_card",  # NEW!
            "data": {
                "action": "purchase",
                "target": "product"
            }
        }
    })
    
    # Demo 3: Additive - Multiple new fields
    demos.append({
        "filename": "03_additive_multiple_fields.json",
        "description": "➕➕ Multiple new fields: device_type, loyalty_points",
        "expected": "ADDITIVE → Validate and approve",
        "data": {
            "id": "demo-003",
            "timestamp": 1704067200000,
            "event_type": "user_action",
            "user_id": "user-9012",
            "device_type": "mobile",        # NEW!
            "loyalty_points": 500,          # NEW!
            "data": {
                "action": "view",
                "target": "page"
            }
        }
    })
    
    # Demo 4: Breaking - Type change (timestamp)
    demos.append({
        "filename": "04_breaking_type_change_timestamp.json",
        "description": "❌ BREAKING: timestamp changed from number to string",
        "expected": "BREAKING → Quarantine and alert",
        "data": {
            "id": "demo-004",
            "timestamp": "2024-01-05T10:30:00Z",  # Was number, now string!
            "event_type": "user_action",
            "user_id": "user-3456",
            "data": {
                "action": "click",
                "target": "button"
            }
        }
    })
    
    # Demo 5: Breaking - Type change (user_id)
    demos.append({
        "filename": "05_breaking_type_change_user_id.json",
        "description": "❌ BREAKING: user_id changed from string to number",
        "expected": "BREAKING → Quarantine and alert",
        "data": {
            "id": "demo-005",
            "timestamp": 1704067200000,
            "event_type": "user_action",
            "user_id": 7890,  # Was string, now number!
            "data": {
                "action": "search",
                "target": "product"
            }
        }
    })
    
    # Demo 6: Invalid - Missing timestamp
    demos.append({
        "filename": "06_invalid_missing_timestamp.json",
        "description": "🚨 INVALID: Missing required field 'timestamp'",
        "expected": "INVALID → Quarantine immediately",
        "data": {
            "id": "demo-006",
            # timestamp MISSING!
            "event_type": "user_action",
            "user_id": "user-1111",
            "data": {
                "action": "click",
                "target": "link"
            }
        }
    })
    
    # Demo 7: Invalid - Missing user_id
    demos.append({
        "filename": "07_invalid_missing_user_id.json",
        "description": "🚨 INVALID: Missing required field 'user_id'",
        "expected": "INVALID → Quarantine immediately",
        "data": {
            "id": "demo-007",
            "timestamp": 1704067200000,
            "event_type": "system_event",
            # user_id MISSING!
            "data": {
                "action": "error",
                "target": "system"
            }
        }
    })
    
    # Demo 8: Nested structure added
    demos.append({
        "filename": "08_additive_nested_structure.json",
        "description": "🌳 Nested structure added: metadata with geo info",
        "expected": "ADDITIVE → Validate and approve",
        "data": {
            "id": "demo-008",
            "timestamp": 1704067200000,
            "event_type": "user_action",
            "user_id": "user-2222",
            "metadata": {  # NEW nested structure!
                "ip_address": "192.168.1.100",
                "geo": {
                    "country": "US",
                    "city": "New York",
                    "lat": 40.7128,
                    "lon": -74.0060
                }
            },
            "data": {
                "action": "purchase",
                "target": "product"
            }
        }
    })
    
    # Demo 9: Complex realistic e-commerce event
    demos.append({
        "filename": "09_realistic_ecommerce_order.json",
        "description": "🛒 Realistic e-commerce order with new fields",
        "expected": "ADDITIVE → Validate and approve",
        "data": {
            "id": "demo-009",
            "timestamp": 1704067200000,
            "event_type": "order_placed",
            "user_id": "user-3333",
            "order_total": 299.99,           # NEW!
            "currency": "USD",               # NEW!
            "items_count": 3,                # NEW!
            "shipping_method": "express",    # NEW!
            "promo_code": "SAVE20",          # NEW!
            "data": {
                "action": "checkout",
                "target": "cart"
            }
        }
    })
    
    # Demo 10: Multiple issues (breaking + missing)
    demos.append({
        "filename": "10_multiple_issues.json",
        "description": "💥 Multiple issues: type change + missing field",
        "expected": "BREAKING → Quarantine and alert",
        "data": {
            "id": "demo-010",
            "timestamp": "invalid-timestamp",  # Type changed!
            "event_type": "user_action",
            # user_id MISSING!
            "data": {
                "action": "error",
                "target": "unknown"
            }
        }
    })
    
    # Write files and create demo script
    demo_script = []
    
    for i, demo in enumerate(demos, 1):
        filepath = Path(output_dir) / demo["filename"]
        
        with open(filepath, 'w') as f:
            json.dump(demo["data"], f, indent=2)
        
        demo_script.append(f"""
{'='*70}
Demo {i}/10: {demo['filename']}
{'='*70}

📝 Description: {demo['description']}
🎯 Expected: {demo['expected']}

📄 File content:
{json.dumps(demo['data'], indent=2)}

⏳ Upload to S3:
aws s3 cp {filepath} s3://YOUR_RAW_BUCKET/data/demo/

⏱️  Wait 45 seconds for processing...

✅ Check results:
- Step Functions Console
- CloudWatch Logs
- DynamoDB schema_history table

""")
        
        print(f"✅ Created: {demo['filename']}")
        print(f"   {demo['description']}")
    
    # Save demo script
    script_file = Path(output_dir) / "DEMO_SCRIPT.txt"
    with open(script_file, 'w') as f:
        f.write("🎬 SchemaGuard AI - Live Demo Script\n")
        f.write("="*70 + "\n\n")
        f.write("Total Time: ~10 minutes\n")
        f.write("Files: 10 (one per scenario)\n\n")
        f.write(''.join(demo_script))
    
    # Create quick upload script
    upload_script = Path(output_dir) / "upload_demo_files.sh"
    with open(upload_script, 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("# Quick upload script for demo files\n\n")
        f.write("RAW_BUCKET=$1\n\n")
        f.write('if [ -z "$RAW_BUCKET" ]; then\n')
        f.write('  echo "Usage: ./upload_demo_files.sh <raw-bucket-name>"\n')
        f.write('  exit 1\n')
        f.write('fi\n\n')
        f.write('echo "🚀 Uploading demo files to $RAW_BUCKET"\n')
        f.write('echo ""\n\n')
        
        for demo in demos:
            f.write(f'echo "📤 Uploading {demo["filename"]}..."\n')
            f.write(f'aws s3 cp tests/demo/{demo["filename"]} s3://$RAW_BUCKET/data/demo/{demo["filename"]}\n')
            f.write('echo "   ✅ Uploaded"\n')
            f.write('echo "   ⏳ Waiting 5 seconds..."\n')
            f.write('sleep 5\n')
            f.write('echo ""\n\n')
        
        f.write('echo "✅ All demo files uploaded!"\n')
        f.write('echo ""\n')
        f.write('echo "📊 Monitor processing:"\n')
        f.write('echo "   - Step Functions: https://console.aws.amazon.com/states/"\n')
        f.write('echo "   - CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/"\n')
        f.write('echo "   - DynamoDB: https://console.aws.amazon.com/dynamodb/"\n')
    
    upload_script.chmod(0o755)
    
    # Create demo summary
    summary = {
        "demo_version": "1.0",
        "created_at": datetime.utcnow().isoformat(),
        "total_files": len(demos),
        "estimated_time_minutes": 10,
        "scenarios": {
            "baseline": 1,
            "additive": 4,
            "breaking": 2,
            "invalid": 2,
            "complex": 1
        },
        "files": [
            {
                "filename": d["filename"],
                "description": d["description"],
                "expected": d["expected"]
            }
            for d in demos
        ]
    }
    
    summary_file = Path(output_dir) / "demo_summary.json"
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)
    
    print()
    print("=" * 70)
    print("✅ Demo Files Ready!")
    print("=" * 70)
    print()
    print(f"📁 Location: {output_dir}/")
    print(f"📝 Files: {len(demos)}")
    print(f"⏱️  Estimated demo time: 10 minutes")
    print()
    print("📋 Files created:")
    for demo in demos:
        print(f"   • {demo['filename']}")
    print()
    print("🎬 To run demo:")
    print(f"   1. Review: {script_file}")
    print(f"   2. Upload: ./tests/demo/upload_demo_files.sh <bucket-name>")
    print("   3. Monitor AWS Console")
    print("   4. Show results")
    print()
    print("💡 Pro tip: Upload files one at a time during recording")
    print("   to show real-time processing!")
    print()

if __name__ == "__main__":
    generate_demo_files()
