<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Find Profile - E-Commerce</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .input-card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); text-align: center; width: 350px; }
        h2 { color: #343a40; margin-bottom: 20px; }
        input[type="number"] { width: 100%; padding: 12px; margin: 15px 0; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { background: #007bff; color: white; border: none; padding: 12px; width: 100%; border-radius: 4px; cursor: pointer; font-size: 16px; font-weight: bold; }
        button:hover { background: #0056b3; }
        .back-link { display: block; margin-top: 15px; color: #666; text-decoration: none; font-size: 14px; }
    </style>
</head>
<body>
    <div class="input-card">
        <h2>👤 View Profile</h2>
        <form action="profile" method="GET">
            <label for="customerId">Enter Customer ID</label>
            <input type="number" id="customerId" name="customerId" required placeholder="e.g., 1">
            <button type="submit">Retrieve Profile</button>
        </form>
        <a href="products" class="back-link">← Back to Store</a>
    </div>
</body>
</html>