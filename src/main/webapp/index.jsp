<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.ecommerce.soa.ProductServlet.Product" %>

<%
    // If products attribute is null, redirect to servlet
    if (request.getAttribute("products") == null) {
        response.sendRedirect("products");
        return;
    }

    // Initialize cart in session if it doesn't exist
    Map<String, Map<String, Object>> cart = (Map<String, Map<String, Object>>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<>();
        session.setAttribute("cart", cart);
    }

    // Calculate cart totals
    int cartItemCount = 0;
    double cartTotal = 0.0;
    for (Map<String, Object> item : cart.values()) {
        int qty = (Integer) item.get("quantity");
        double price = (Double) item.get("price");
        cartItemCount += qty;
        cartTotal += price * qty;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>E-Commerce Store</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* NAVBAR */
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
            text-decoration: none;
        }

        .navbar a:hover {
            text-decoration: underline;
        }

        .cart-badge {
            background: #dc3545;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            margin-left: 5px;
        }

        /* MESSAGES */
        .message {
            max-width: 1200px;
            margin: 20px auto;
            padding: 15px;
            border-radius: 4px;
            text-align: center;
        }

        .error {
            background: #f8d7da;
            color: #721c24;
        }

        .success {
            background: #d4edda;
            color: #155724;
        }

        /* MAIN CONTENT */
        .container {
            flex: 1;
            padding: 40px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* SHOPPING CART SUMMARY */
        .cart-summary {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            width: 100%;
            max-width: 1200px;
        }

        .cart-summary h3 {
            margin-top: 0;
            color: #343a40;
        }

        .cart-items {
            margin: 15px 0;
        }

        .cart-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid #eee;
        }

        .cart-item:last-child {
            border-bottom: none;
        }

        .cart-item strong {
            display: block;
            margin-bottom: 5px;
        }

        .cart-item small {
            color: #666;
        }

        .cart-total {
            font-size: 20px;
            font-weight: bold;
            color: #007bff;
            text-align: right;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 2px solid #dee2e6;
        }

        .btn-checkout {
            background: #28a745;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 15px;
        }

        .btn-checkout:hover {
            background: #218838;
        }

        .btn-clear-cart {
            background: #dc3545;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            margin-left: 10px;
        }

        .btn-clear-cart:hover {
            background: #c82333;
        }

        .btn-remove {
            background: #6c757d;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }

        .btn-remove:hover {
            background: #5a6268;
        }

        .empty-cart {
            text-align: center;
            color: #666;
            padding: 40px;
        }

        .empty-cart h3 {
            color: #999;
        }

        /* PRODUCTS */
        .products {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
            max-width: 1200px;
            width: 100%;
        }

        .product {
            background: white;
            padding: 25px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }

        .product:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }

        .product h3 {
            margin-top: 0;
            color: #343a40;
        }

        .product p {
            margin: 8px 0;
        }

        .product .price {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
            margin: 15px 0;
        }

        .product input[type="number"] {
            width: 60px;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-align: center;
        }

        .product button {
            margin-top: 15px;
            padding: 10px 20px;
            background: #007bff;
            border: none;
            color: white;
            cursor: pointer;
            border-radius: 4px;
            font-size: 14px;
            font-weight: bold;
            width: 100%;
        }

        .product button:hover {
            background: #0056b3;
        }

        .product button:disabled {
            background: #6c757d;
            cursor: not-allowed;
        }

        .stock-info {
            font-size: 13px;
            color: #28a745;
            font-weight: bold;
        }

        .out-of-stock {
            color: #dc3545;
            font-weight: bold;
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

<!-- NAVBAR -->
<div class="navbar">
    <h2>🛒 E-Commerce Store</h2>
    <div>
        <a href="products">🏠 Home</a>
        <% if (session.getAttribute("customer_name") != null) { %>
            <span style="color: #28a745;">Welcome, <%= session.getAttribute("customer_name") %>!</span>
            <a href="profile">👤 My Profile</a>
        <% } else { %>
            <a href="profile_input.jsp">👤 Login/Find Profile</a>
        <% } %>
        <a href="#cart">🛒 Cart <span class="cart-badge"><%= cartItemCount %></span></a>
    </div>
</div>
<!-- MESSAGES -->
<%
    String message = (String) session.getAttribute("message");
    String messageType = (String) session.getAttribute("messageType");
    if (message != null) {
%>
<div class="message <%= "error".equals(messageType) ? "error" : "success" %>">
    <%= message %>
</div>
<%
        session.removeAttribute("message");
        session.removeAttribute("messageType");
    }

    String error = (String) request.getAttribute("error");
    if (error != null) {
%>
<div class="message error">
    <%= error %>
</div>
<%
    }
%>

<div class="container">

    <!-- SHOPPING CART SUMMARY (Shown when cart has items) -->
    <% if (!cart.isEmpty()) { %>
    <div class="cart-summary" id="cart">
        <h3>🛒 Shopping Cart (<%= cartItemCount %> items)</h3>
        <div class="cart-items">
            <%
                for (Map.Entry<String, Map<String, Object>> entry : cart.entrySet()) {
                    String productId = entry.getKey();
                    Map<String, Object> item = entry.getValue();
                    String productName = (String) item.get("product_name");
                    double price = (Double) item.get("price");
                    int quantity = (Integer) item.get("quantity");
                    double itemTotal = price * quantity;
            %>
            <div class="cart-item">
                <div>
                    <strong><%= productName %></strong><br>
                    <small>$<%= String.format("%.2f", price) %> × <%= quantity %> = $<%= String.format("%.2f", itemTotal) %></small>
                </div>
                <form action="cart" method="post" style="margin: 0;">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="product_id" value="<%= productId %>">
                    <button type="submit" class="btn-remove">Remove</button>
                </form>
            </div>
            <%
                }
            %>
        </div>
        <div class="cart-total">
            Total: $<%= String.format("%.2f", cartTotal) %>
        </div>
        <div style="margin-top: 20px;">
            <form action="checkout.jsp" method="get" style="display: inline;">
                <button type="submit" class="btn-checkout">✓ Proceed to Checkout</button>
            </form>
            <form action="cart" method="post" style="display: inline;">
                <input type="hidden" name="action" value="clear">
                <button type="submit" class="btn-clear-cart">✗ Clear Cart</button>
            </form>
        </div>
    </div>
    <% } else { %>
    <!-- EMPTY CART MESSAGE -->
    <div class="cart-summary" id="cart">
        <div class="empty-cart">
            <h3>🛒 Your cart is empty</h3>
            <p>Browse our products below and add items to your cart!</p>
        </div>
    </div>
    <% } %>

    <!-- PRODUCT CATALOG -->
    <h2 style="width: 100%; max-width: 1200px; margin: 30px 0 20px 0;">Available Products</h2>

    <div class="products">
        <%
            List<Product> products = (List<Product>) request.getAttribute("products");
            if (products != null && !products.isEmpty()) {
                for (Product product : products) {
                    boolean inStock = product.getQuantity_available() > 0;
        %>

        <div class="product">
            <h3><%= product.getProduct_name() %></h3>
            <p class="price">$<%= String.format("%.2f", product.getUnit_price()) %></p>
            <p class="stock-info">
                <% if (inStock) { %>
                ✓ In Stock: <%= product.getQuantity_available() %> available
                <% } else { %>
                <span class="out-of-stock">✗ Out of Stock</span>
                <% } %>
            </p>

            <form action="cart" method="post">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="product_id" value="<%= product.getProduct_id() %>">
                <input type="hidden" name="product_name" value="<%= product.getProduct_name() %>">
                <input type="hidden" name="price" value="<%= product.getUnit_price() %>">

                <label for="qty_<%= product.getProduct_id() %>">Quantity:</label>
                <input type="number"
                       id="qty_<%= product.getProduct_id() %>"
                       name="quantity"
                       value="1"
                       min="1"
                       max="<%= product.getQuantity_available() %>"
                    <%= !inStock ? "disabled" : "" %>>

                <button type="submit" <%= !inStock ? "disabled" : "" %>>
                    <%= inStock ? "🛒 Add to Cart" : "Out of Stock" %>
                </button>
            </form>
        </div>

        <%
            }
        } else {
        %>
        <div style="text-align: center; width: 100%; padding: 40px; grid-column: 1 / -1;">
            <h3>No products available</h3>
            <p>Please check back later or contact support.</p>
        </div>
        <%
            }
        %>
    </div>
</div>

<!-- FOOTER -->
<footer>
    © 2025 E-Commerce Order Management System
</footer>

</body>
</html>
