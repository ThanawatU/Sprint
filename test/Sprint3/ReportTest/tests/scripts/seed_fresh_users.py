"""
seed_fresh_users.py
สร้าง fresh test users สำหรับ TC_Report_HappyPath suite
รันก่อนทุกครั้งที่จะ run suite นี้

ใช้งาน:
    python seed_fresh_users.py
    python seed_fresh_users.py --base-url http://staging.example.com/api
"""

import requests
import argparse
import sys

# ── Config ────────────────────────────────────────────────────────────────────
DEFAULT_BASE_URL = "http://localhost:3000/api"

FRESH_USERS = [
    {
        "email": "fresh_report_1@test.com",
        "password": "Password1234!",
        "firstName": "Fresh",
        "lastName": "Report1",
        "role": "PASSENGER",
        "phoneNumber": "0811111111",
    },
    {
        "email": "fresh_report_2@test.com",
        "password": "Password1234!",
        "firstName": "Fresh",
        "lastName": "Report2",
        "role": "PASSENGER",
        "phoneNumber": "0822222222",
    },
]

# ── Helpers ───────────────────────────────────────────────────────────────────
def login(base_url: str, email: str, password: str) -> str | None:
    """Login แล้วคืน token"""
    res = requests.post(f"{base_url}/auth/login", json={"email": email, "password": password})
    if res.ok:
        return res.json().get("access_token") or res.json().get("token")
    return None


def register(base_url: str, user: dict) -> bool:
    """สมัครสมาชิก คืน True ถ้าสำเร็จหรือมีอยู่แล้ว"""
    res = requests.post(f"{base_url}/auth/register", json=user)
    if res.ok:
        print(f"  ✅ สร้างสำเร็จ: {user['email']}")
        return True
    if res.status_code == 409:
        print(f"  ℹ️  มีอยู่แล้ว: {user['email']}")
        return True
    print(f"  ❌ สร้างไม่สำเร็จ: {user['email']} → {res.status_code} {res.text}")
    return False


def delete_all_reports(base_url: str, token: str, email: str):
    """ลบ report ทั้งหมดของ user เพื่อ reset สถานะ"""
    headers = {"Authorization": f"Bearer {token}"}
    res = requests.get(f"{base_url}/reports/me", headers=headers)
    if not res.ok:
        print(f"  ⚠️  ดึง report ไม่ได้สำหรับ {email}: {res.status_code}")
        return
    reports = res.json() if isinstance(res.json(), list) else res.json().get("data", [])
    for r in reports:
        rid = r.get("id") or r.get("groupId")
        if rid:
            requests.delete(f"{base_url}/reports/{rid}", headers=headers)
    print(f"  🗑️  ลบ {len(reports)} report สำหรับ {email}")


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default=DEFAULT_BASE_URL)
    args = parser.parse_args()
    base_url = args.base_url.rstrip("/")

    print(f"\n🔧 Seeding fresh report users → {base_url}\n")
    all_ok = True

    for user in FRESH_USERS:
        print(f"👤 {user['email']}")
        ok = register(base_url, user)
        if not ok:
            all_ok = False
            continue

        # Login แล้วลบ report เก่าทิ้ง (reset สถานะ)
        token = login(base_url, user["email"], user["password"])
        if token:
            delete_all_reports(base_url, token, user["email"])
        else:
            print(f"  ⚠️  Login ไม่สำเร็จ ข้ามการ reset report")

    print("\n✅ Done" if all_ok else "\n❌ มีบาง user สร้างไม่สำเร็จ กรุณาตรวจสอบ")
    sys.exit(0 if all_ok else 1)


if __name__ == "__main__":
    main()
