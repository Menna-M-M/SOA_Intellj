<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>

<%
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> pricedItems =
            (List<Map<String, Object>>) request.getAttribute("pricedItems");

    if (pricedItems == null || pricedItems.isEmpty()) {
        response.sendRedirect("products");
        return;
    }

    Double subtotal = (Double) request.getAttribute("subtotal");
    Double tax = (Double) request.getAttribute("tax");
    Double discount = (Double) request.getAttribute("discount");
    Double finalTotal = (Double) request.getAttribute("finalTotal");

    if (subtotal == null) subtotal = 0.0;
    if (tax == null) tax = 0.0;
    if (discount == null) discount = 0.0;
    if (finalTotal == null) finalTotal = subtotal;
%>

<!DOCTYPE html>
<html>
<head>
    <title>Checkout</title>
    <style>
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

        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
        }
        .container {
            max-width: 1000px;
            margin: 40px auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
        }
        .item {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #eee;
            padding: 12px 0;
        }
        .item-details {
            flex: 1;
        }
        .item-price {
            text-align: right;
            min-width: 200px;
        }
        .old {
            text-decoration: line-through;
            color: #999;
        }
        .discount {
            color: #dc3545;
            font-size: 14px;
        }
        .final {
            font-weight: bold;
            color: #28a745;
        }
        .total {
            font-size: 18px;
            font-weight: bold;
            margin-top: 10px;
            text-align: right;
        }
        .grand {
            font-size: 22px;
            color: #007bff;
        }
        .form-group {
            margin: 20px 0;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #343a40;
        }
        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .btn {
            width: 100%;
            padding: 15px;
            margin-top: 20px;
            background: #28a745;
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
            border-radius: 4px;
            font-weight: bold;
        }
        .btn:hover {
            background: #218838;
        }
        .btn-secondary {
            background: #6c757d;
            margin-top: 10px;
        }
        .btn-secondary:hover {
            background: #5a6268;
        }
        footer {
            background: #343a40;
            color: white;
            text-align: center;
            padding: 15px;
            margin-top: 40px;
        }
    </style>
</head>

<body>

<div class="navbar">
    <h2>🛒 E-Commerce</h2>
    <div>
        <a href="products">🏠 Home</a>
        <a href="products">📦 Products</a>
        <a href="profile_input.jsp">👤 My Profile</a>
    </div>
</div>

<div class="container">
    <h2>Checkout Summary</h2>

    <form action="${pageContext.request.contextPath}/submitOrder" method="post">

        <!-- Hidden field for total amount -->
        <input type="hidden" name="total_amount" value="<%= finalTotal %>">

        <!-- Hidden field for number of products -->
        <input type="hidden" name="product_count" value="<%= pricedItems.size() %>">

        <!-- Hidden fields for each product -->
        <%
            int itemIndex = 0;
            for (Map<String, Object> item : pricedItems) {
                // Get product_id - handle both Integer and Double from JSON
                Object productIdObj = item.get("product_id");
                int productId;
                if (productIdObj instanceof Double) {
                    productId = ((Double) productIdObj).intValue();
                } else {
                    productId = (Integer) productIdObj;
                }

                // Get quantity - handle both Integer and Double from JSON
                Object quantityObj = item.get("quantity");
                int quantity;
                if (quantityObj instanceof Double) {
                    quantity = ((Double) quantityObj).intValue();
                } else {
                    quantity = (Integer) quantityObj;
                }
        %>
        <input type="hidden" name="product_id_<%= itemIndex %>" value="<%= productId %>">
        <input type="hidden" name="quantity_<%= itemIndex %>" value="<%= quantity %>">
        <%
                itemIndex++;
            }
        %>

        <!-- Display order items -->
        <% for (Map<String, Object> item : pricedItems) { %>
        <div class="item">
            <div class="item-details">
                <strong><%= item.get("product_name") %></strong><br>
                Qty: <%= ((Number) item.get("quantity")).intValue() %>
            </div>

            <div class="item-price">
                <div class="old">
                    $<%= String.format("%.2f", ((Number) item.get("line_total")).doubleValue()) %>
                </div>

                <div class="discount">
                    - <%= String.format("%.1f", ((Number) item.get("discount_percentage")).doubleValue()) %>%
                    ($<%= String.format("%.2f", ((Number) item.get("discount_amount")).doubleValue()) %>)
                </div>

                <div class="final">
                    $<%= String.format("%.2f", ((Number) item.get("final_price")).doubleValue()) %>
                </div>
            </div>
        </div>
        <% } %>

        <hr>

        <div class="total">Subtotal: $<%= String.format("%.2f", subtotal) %></div>
        <div class="total">Tax: $<%= String.format("%.2f", tax) %></div>
        <div class="total">Total Discount: -$<%= String.format("%.2f", discount) %></div>
        <div class="total grand">Grand Total: $<%= String.format("%.2f", finalTotal) %></div>

        <div class="form-group">
            <label for="customer_id">Customer ID *</label>
            <input type="number" id="customer_id" name="customer_id"
                   placeholder="Enter your customer ID" required>
        </div>

        <button type="submit" class="btn">
            Place Order ($<%= String.format("%.2f", finalTotal) %>)
        </button>
    </form>

    <form action="products" method="get">
        <button type="submit" class="btn btn-secondary">Continue Shopping</button>
    </form>
</div>

<footer>
    © 2025 E-Commerce Order Management System
</footer>

</body>
</html>