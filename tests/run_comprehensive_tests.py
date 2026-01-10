#!/usr/bin/env python3
"""
Test Runner for SchemaGuard AI
Uploads test files to S3 and measures real performance
"""

import json
import boto3
import time
from pathlib import Path
from datetime import datetime
import sys

def run_tests(raw_bucket, test_dir="tests/generated"):
    """Run comprehensive tests and collect metrics"""
    
    s3_client = boto3.client('s3')
    sfn_client = boto3.client('stepfunctions')
    
    print("🚀 Starting Comprehensive Test Run")
    print("=" * 70)
    print()
    
    test_files = list(Path(test_dir).glob("*.json"))
    test_files = [f for f in test_files if f.name not in ["test_statistics.json", "expected_results.json"]]
    
    print(f"📁 Found {len(test_files)} test files")
    print(f"📤 Uploading to S3 bucket: {raw_bucket}")
    print()
    
    results = {
        "test_run_id": f"test-{int(time.time())}",
        "started_at": datetime.utcnow().isoformat(),
        "bucket": raw_bucket,
        "files_uploaded": 0,
        "upload_time_seconds": 0,
        "files": [],
        "errors": []
    }
    
    start_time = time.time()
    
    # Upload files in batches
    batch_size = 50
    for i in range(0, len(test_files), batch_size):
        batch = test_files[i:i+batch_size]
        batch_start = time.time()
        
        print(f"📤 Uploading batch {i//batch_size + 1}/{(len(test_files)-1)//batch_size + 1} ({len(batch)} files)...")
        
        for test_file in batch:
            try:
                s3_key = f"data/test/{test_file.name}"
                
                with open(test_file, 'rb') as f:
                    s3_client.put_object(
                        Bucket=raw_bucket,
                        Key=s3_key,
                        Body=f.read()
                    )
                
                results["files"].append({
                    "filename": test_file.name,
                    "s3_key": s3_key,
                    "uploaded_at": datetime.utcnow().isoformat(),
                    "size_bytes": test_file.stat().st_size
                })
                results["files_uploaded"] += 1
                
            except Exception as e:
                results["errors"].append({
                    "filename": test_file.name,
                    "error": str(e)
                })
                print(f"   ❌ Error uploading {test_file.name}: {e}")
        
        batch_time = time.time() - batch_start
        print(f"   ✅ Batch uploaded in {batch_time:.2f}s")
        
        # Small delay between batches to avoid throttling
        if i + batch_size < len(test_files):
            time.sleep(2)
    
    results["upload_time_seconds"] = time.time() - start_time
    results["completed_at"] = datetime.utcnow().isoformat()
    
    print()
    print("=" * 70)
    print("✅ Upload Complete!")
    print("=" * 70)
    print()
    print(f"📊 Upload Statistics:")
    print(f"   Files uploaded: {results['files_uploaded']}")
    print(f"   Errors: {len(results['errors'])}")
    print(f"   Total time: {results['upload_time_seconds']:.2f} seconds")
    print(f"   Avg time per file: {results['upload_time_seconds']/results['files_uploaded']:.3f} seconds")
    print()
    
    # Save results
    results_file = Path(test_dir) / "upload_results.json"
    with open(results_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"💾 Results saved to: {results_file}")
    print()
    print("⏳ Now wait for SchemaGuard to process all files...")
    print("   Monitor: AWS Step Functions Console")
    print("   Check: CloudWatch Logs")
    print()
    print("📝 After processing completes, run:")
    print("   python tests/analyze_results.py")
    print()
    
    return results

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python run_comprehensive_tests.py <raw-bucket-name>")
        print()
        print("Example:")
        print("  python run_comprehensive_tests.py schemaguard-ai-dev-raw-123456789")
        sys.exit(1)
    
    raw_bucket = sys.argv[1]
    run_tests(raw_bucket)
