retry_count: int = 0
max_retries: int = 3

while retry_count < max_retries:
    print(f"Attempt deploment.. Attempt number: {retry_count + 1}")
    retry_count += 1

print(f"Final retry state: {retry_count}")