<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>

<%
    Boolean orderSuccess = (Boolean) session.getAttribute("orderSuccess");
    if (orderSuccess == null || !orderSuccess) {
        response.sendRedirect("products");
        return;
    }

    String orderId = (String) session.getAttribute("orderId");
    String orderTotal = (String) session.getAttribute("orderTotal");
    String customerId = (String) session.getAttribute("customerId");

    Integer loyaltyPointsEarned = (Integer) session.getAttribute("loyaltyPointsEarned");
    Boolean loyaltyUpdated = (Boolean) session.getAttribute("loyaltyUpdated");
    Boolean notificationSent = (Boolean) session.getAttribute("notificationSent");

    @SuppressWarnings("unchecked")
    Map<String, Object> orderResponse = (Map<String, Object>) session.getAttribute("orderResponse");

    // Set defaults
    if (loyaltyPointsEarned == null) loyaltyPointsEarned = 0;
    if (loyaltyUpdated == null) loyaltyUpdated = false;
    if (notificationSent == null) notificationSent = false;

    // Clear the success flag but keep other data for display
    session.removeAttribute("orderSuccess");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Order Confirmation</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .navbar {
            background: #343a40;
            color: white;
            padding: 15px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar a {
            color: white;
            text-decoration: none;
            margin-left: 20px;
        }

        .container {
            flex: 1;
            padding: 40px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .confirmation-box {
            background: white;
            padding: 50px;
            border-radius: 8px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 600px;
            width: 100%;
        }

        .success-icon {
            font-size: 80px;
            color: #28a745;
            margin-bottom: 20px;
            animation: scaleIn 0.5s ease-in-out;
        }

        @keyframes scaleIn {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
        }

        h1 {
            color: #28a745;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #666;
            font-size: 16px;
            margin-bottom: 30px;
        }

        .order-details {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 4px;
            margin: 30px 0;
            text-align: left;
        }

        .order-details h3 {
            margin-top: 0;
            color: #343a40;
            border-bottom: 2px solid #dee2e6;
            padding-bottom: 10px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #dee2e6;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            color: #666;
            font-weight: 500;
        }

        .detail-value {
            color: #343a40;
            font-weight: bold;
        }

        .total-amount {
            font-size: 24px;
            color: #007bff;
        }

        .status-badge {
            display: inline-block;
            padding: 5px 15px;
            background: #28a745;
            color: white;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
        }

        .loyalty-badge {
            display: inline-block;
            padding: 8px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 25px;
            font-size: 18px;
            font-weight: bold;
            margin: 20px 0;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .loyalty-section {
            background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #667eea;
        }

        .loyalty-section h3 {
            color: #667eea;
            margin-top: 0;
        }

        .info-message {
            background: #d1ecf1;
            color: #0c5460;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
            border-left: 4px solid #17a2b8;
        }

        .btn {
            display: inline-block;
            padding: 12px 30px;
            margin: 10px;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: bold;
            transition: background 0.3s;
        }

        .btn-primary {
            background: #007bff;
        }

        .btn-primary:hover {
            background: #0056b3;
        }

        .btn-secondary {
            background: #6c757d;
        }

        .btn-secondary:hover {
            background: #5a6268;
        }

        footer {
            background: #343a40;
            color: white;
            text-align: center;
            padding: 15px;
        }
    </style>
</head>

<body>

<!-- NAVBAR -->
<div class="navbar">
    <h2>🛒 E-Commerce</h2>
    <div>
        <a href="products">🏠 Home</a>
        <a href="products">📦 Products</a>
    </div>
</div>

<!-- CONFIRMATION -->
<div class="container">
    <div class="confirmation-box">
        <div class="success-icon">✓</div>
        <h1>Order Placed Successfully!</h1>
        <p class="subtitle">Thank you for your purchase. Your order has been confirmed.</p>

        <div class="order-details">
            <h3>Order Details</h3>

            <div class="detail-row">
                <span class="detail-label">Order ID:</span>
                <span class="detail-value">#<%= orderId %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Customer ID:</span>
                <span class="detail-value"><%= customerId %></span>
            </div>

            <% if (orderResponse != null && orderResponse.get("timestamp") != null) { %>
            <div class="detail-row">
                <span class="detail-label">Order Date:</span>
                <span class="detail-value"><%= orderResponse.get("timestamp") %></span>
            </div>
            <% } %>

            <div class="detail-row">
                <span class="detail-label">Total Amount:</span>
                <span class="detail-value total-amount">$<%= String.format("%.2f", Double.parseDouble(orderTotal)) %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value"><span class="status-badge">Confirmed</span></span>
            </div>
        </div>

        <% if (loyaltyPointsEarned > 0) { %>
        <div class="loyalty-section">
            <h3>🎉 Loyalty Points Earned!</h3>
            <div class="loyalty-badge">
                + <%= loyaltyPointsEarned %> Points
            </div>
            <p style="color: #666; margin: 10px 0;">
                You earned <strong><%= loyaltyPointsEarned %></strong> loyalty points from this purchase!
                <br>
                <small>(1 point per 10 EGP spent)</small>
            </p>
            <% if (!loyaltyUpdated) { %>
            <p style="color: #dc3545; font-size: 14px;">
                ⚠️ Note: Loyalty points will be updated shortly
            </p>
            <% } %>
        </div>
        <% } %>

        <% if (notificationSent) { %>
        <div class="info-message">
            <strong>📧 Confirmation Email Sent</strong><br>
            We've sent you an email confirmation with your order details and delivery estimates.
        </div>
        <% } else { %>
        <div class="info-message">
            <strong>📧 Email Notification</strong><br>
            An email confirmation will be sent to you shortly with your order details.
        </div>
        <% } %>

        <div style="margin-top: 30px;">
            <a href="products" class="btn btn-primary">Continue Shopping</a>
            <a href="products" class="btn btn-secondary">View Products</a>
        </div>
    </div>
</div>

<!-- FOOTER -->
<footer>
    © 2025 E-Commerce Order Management System
</footer>

</body>
</html>