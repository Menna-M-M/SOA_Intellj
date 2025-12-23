<!-- CHECKOUT FORM -->
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.Map" %>

    <%
      // Get cart from session
      @SuppressWarnings("unchecked")
      Map<String, Map<String, Object>> cart =
              (Map<String, Map<String, Object>>) session.getAttribute("cart");

      // If cart is empty, redirect to products
      if (cart == null || cart.isEmpty()) {
        response.sendRedirect("products");
        return;
      }

      // Calculate totals
      double cartTotal = 0.0;
      int totalItems = 0;
      for (Map<String, Object> item : cart.values()) {
        int qty = (Integer) item.get("quantity");
        double price = (Double) item.get("price");
        cartTotal += price * qty;
        totalItems += qty;
      }
    %>

    <!DOCTYPE html>
    <html>
    <head>
      <title>Checkout</title>
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
          align-items: flex-start;
        }

        .checkout-wrapper {
          display: flex;
          gap: 30px;
          max-width: 1200px;
          width: 100%;
        }

        .order-summary {
          flex: 1;
          background: white;
          padding: 30px;
          border-radius: 8px;
          box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        .checkout-form {
          flex: 1;
          background: white;
          padding: 30px;
          border-radius: 8px;
          box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        h2 {
          margin-top: 0;
          color: #343a40;
        }

        .order-item {
          display: flex;
          justify-content: space-between;
          padding: 15px 0;
          border-bottom: 1px solid #eee;
        }

        .order-item:last-child {
          border-bottom: none;
        }

        .item-details {
          flex: 1;
        }

        .item-details strong {
          display: block;
          margin-bottom: 5px;
        }

        .item-details small {
          color: #666;
        }

        .item-price {
          text-align: right;
          font-weight: bold;
        }

        .order-total {
          font-size: 24px;
          font-weight: bold;
          color: #007bff;
          text-align: right;
          margin-top: 20px;
          padding-top: 20px;
          border-top: 2px solid #dee2e6;
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

        .form-group input,
        .form-group textarea {
          width: 100%;
          padding: 12px;
          border: 1px solid #ddd;
          border-radius: 4px;
          box-sizing: border-box;
          font-family: Arial, sans-serif;
        }

        .form-group textarea {
          resize: vertical;
          min-height: 80px;
        }

        .btn {
          width: 100%;
          padding: 15px;
          background: #28a745;
          color: white;
          border: none;
          border-radius: 4px;
          font-size: 18px;
          cursor: pointer;
          margin-top: 20px;
          font-weight: bold;
        }

        .btn:hover {
          background: #218838;
        }

        .btn-secondary {
          background: #6c757d;
          margin-top: 10px;
          font-size: 16px;
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

        @media (max-width: 768px) {
          .checkout-wrapper {
            flex-direction: column;
          }
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
        <a href="products#cart">🛒 Cart</a>
      </div>
    </div>

    <!-- CHECKOUT -->
    <div class="container">
      <div class="checkout-wrapper">

        <!-- CHECKOUT FORM -->
        <div class="checkout-form">
          <form action="${pageContext.request.contextPath}/submitOrder" method="post">

            <!-- ORDER SUMMARY -->
            <div class="order-summary">
              <h2>Order Summary</h2>
              <p style="color: #666; margin-bottom: 20px;"><%= totalItems %> items</p>

              <%
                for (Map.Entry<String, Map<String, Object>> entry : cart.entrySet()) {
                  Map<String, Object> item = entry.getValue();
                  String productName = (String) item.get("product_name");
                  double price = (Double) item.get("price");
                  int quantity = (Integer) item.get("quantity");
                  double itemTotal = price * quantity;
              %>
              <div class="order-item">
                <div class="item-details">
                  <strong><%= productName %></strong>
                  <small>Qty: <%= quantity %> × $<%= String.format("%.2f", price) %></small>
                </div>
                <div class="item-price">
                  $<%= String.format("%.2f", itemTotal) %>
                </div>
              </div>
              <%
                }
              %>

              <div class="order-total">
                Total: $<%= String.format("%.2f", cartTotal) %>
              </div>
            </div>

            <button type="submit" class="btn">Place Order ($<%= String.format("%.2f", cartTotal) %>)</button>
          </form>

          <form action="products" method="get">
            <button type="submit" class="btn btn-secondary">Continue Shopping</button>
          </form>
        </div>
      </div>
    </div>

    <!-- FOOTER -->
    <footer>
      © 2025 E-Commerce Order Management System
    </footer>

    </body>
    </html>
