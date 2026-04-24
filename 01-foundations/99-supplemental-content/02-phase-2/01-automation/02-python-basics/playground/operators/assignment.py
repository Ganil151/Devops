retry_count: int = 0
max_retries: int = 5

while retry_count < max_retries:
    print(f"Attempt deployment.. Attempt number: {retry_count + 1}")
    retry_count += 1

print(f"Final retry state: {retry_count}")