<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.ecommerce.soa.Customer" %>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Profile | E-Commerce System</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; margin: 0; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .card { background: white; border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.1); width: 100%; max-width: 450px; padding: 2rem; }
        .header { border-bottom: 2px solid #f0f0f0; padding-bottom: 1rem; margin-bottom: 1.5rem; text-align: center; }
        .header h2 { margin: 0; color: #2d3436; font-size: 1.5rem; }
        .info-group { margin-bottom: 1rem; display: flex; justify-content: space-between; border-bottom: 1px solid #f9f9f9; padding-bottom: 0.5rem; }
        .label { color: #636e72; font-weight: 600; font-size: 0.9rem; }
        .value { color: #2d3436; font-weight: 400; }

        /* Loyalty Section */
        .loyalty-card { background: #e3f2fd; border-radius: 8px; padding: 1.2rem; margin-top: 1.5rem; text-align: center; }
        .loyalty-title { color: #0747a6; font-weight: bold; margin-bottom: 0.5rem; display: block; }
        .points-val { font-size: 2rem; color: #007bff; font-weight: 800; display: block; }

        .footer-btns { display: flex; gap: 10px; margin-top: 2rem; }
        .btn { flex: 1; padding: 0.8rem; border-radius: 6px; text-decoration: none; text-align: center; font-weight: 600; font-size: 0.9rem; transition: 0.2s; }
        .btn-primary { background: #007bff; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn:hover { opacity: 0.9; }
        .error { color: #d63031; text-align: center; font-weight: bold; }
    </style>
</head>
<body>

<div class="card">
    <%
        Customer c = (Customer) request.getAttribute("customer");
        String error = (String) request.getAttribute("error");
        if (c != null) {
    %>
        <div class="header">
            <h2>User Profile</h2>
        </div>

        <div class="info-group">
            <span class="label">Customer ID</span>
            <span class="value">#<%= c.getCustomer_id() %></span>
        </div>
        <div class="info-group">
            <span class="label">Full Name</span>
            <span class="value"><%= c.getName() %></span>
        </div>
        <div class="info-group">
            <span class="label">Email Address</span>
            <span class="value"><%= c.getEmail() %></span>
        </div>
        <div class="info-group">
            <span class="label">Phone Number</span>
            <span class="value"><%= (c.getPhone() != null) ? c.getPhone() : "N/A" %></span>
        </div>

        <div class="loyalty-card">
            <span class="loyalty-title">LOYALTY BALANCE</span>
            <span class="points-val"><%= c.getLoyalty_points() %></span>
            <small style="color: #546e7a;">Points earned from orders</small>
        </div>

    <% } else { %>
        <p class="error"><%= (error != null) ? error : "Customer not found." %></p>
    <% } %>

    <div class="footer-btns">
        <a href="profile_input.jsp" class="btn btn-secondary">Switch User</a>
        <a href="products" class="btn btn-primary">Go to Store</a>
    </div>
</div>

</body>
</html>