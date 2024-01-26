import json

# JSON 파일 로드
with open('inbox/flashloan.json', 'r') as f:
    data = json.load(f)

# JSON 데이터에서 'flashloans' 배열을 추출
flashloans = data["data"]["flashloans"]

# 각 'timestamp'를 리스트에 추가
timestamps = [loan["timestamp"] for loan in flashloans]

# 전체 'timestamp'의 개수
total_count = len(timestamps)

# 중복된 'timestamp' 찾기
unique_timestamps = set(timestamps)
duplicate_count = len(timestamps) - len(unique_timestamps)
unique_count = len(unique_timestamps)

print(f"전체 타임스탬프는 총 {total_count}회 있습니다.")
print(f"중복되지 않은 타임스탬프는 총 {unique_count}회 있습니다.")

print(f"중복된 타임스탬프는 총 {duplicate_count}회 있습니다.")