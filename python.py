"""
pandas pd.merge(..., how=...) — same idea as SQL JOINs.

Setup:
  users  → user_id 1,2,3,4  (Kim = 4 has no orders)
  orders → user_id 1,1,2,3,5  (user 5 has orders but is NOT in users)

Key rule: the result is built from the *keys* that survive the join type,
then columns from both frames are aligned on user_id.
"""

import pandas as pd

users = pd.DataFrame(
    {
        "user_id": [1, 2, 3, 4],
        "name": ["Ram", "Amit", "Neha", "Kim"],
    }
)

orders = pd.DataFrame(
    {
        "user_id": [1, 1, 2, 3, 5],
        "order_id": [101, 102, 201, 301, 501],
        "amount": [50.0, 30.0, 120.0, 90.0, 40.0],
    }
)

print("=== users ===\n", users.to_string(index=False), "\n", sep="")
print("=== orders ===\n", orders.to_string(index=False), "\n", sep="")

# INNER — only rows where user_id exists in BOTH tables (like SQL INNER JOIN)
inner = pd.merge(users, orders, on="user_id", how="inner")
print("=== INNER (only keys in both: 1,2,3) ===\n", inner.to_string(index=False), "\n", sep="")

# LEFT — every row from the LEFT frame (users); match orders or NaN (SQL LEFT JOIN)
left = pd.merge(users, orders, on="user_id", how="left")
print("=== LEFT (all users; Kim has no orders → NaN) ===\n", left.to_string(index=False), "\n", sep="")

# RIGHT — every row from the RIGHT frame (orders); match users or NaN (SQL RIGHT JOIN)
right = pd.merge(users, orders, on="user_id", how="right")
print("=== RIGHT (all orders; user_id 5 has no user row → NaN name) ===\n", right.to_string(index=False), "\n", sep="")

# OUTER — any user_id from either side; fill missing side with NaN (SQL FULL OUTER JOIN)
outer = pd.merge(users, orders, on="user_id", how="outer")
print("=== OUTER (union of keys: 1,2,3,4,5) ===\n", outer.to_string(index=False), "\n", sep="")
