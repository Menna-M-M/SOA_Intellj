package org.ecommerce.soa;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        // Get or create cart
        @SuppressWarnings("unchecked")
        Map<String, Map<String, Object>> cart =
                (Map<String, Map<String, Object>>) session.getAttribute("cart");

        if (cart == null) {
            cart = new HashMap<>();
            session.setAttribute("cart", cart);
        }

        if ("add".equals(action)) {
            // Add item to cart
            String productId = request.getParameter("product_id");
            String productName = request.getParameter("product_name");
            double price = Double.parseDouble(request.getParameter("price"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            // Check if product already in cart
            if (cart.containsKey(productId)) {
                // Update quantity
                Map<String, Object> existingItem = cart.get(productId);
                int existingQty = (Integer) existingItem.get("quantity");
                existingItem.put("quantity", existingQty + quantity);
                session.setAttribute("message", "Updated quantity for " + productName);
            } else {
                // Add new item
                Map<String, Object> item = new HashMap<>();
                item.put("product_id", productId);
                item.put("product_name", productName);
                item.put("price", price);
                item.put("quantity", quantity);
                cart.put(productId, item);
                session.setAttribute("message", "Added " + productName + " to cart");
            }
            session.setAttribute("messageType", "success");

        } else if ("remove".equals(action)) {
            // Remove item from cart
            String productId = request.getParameter("product_id");
            if (cart.containsKey(productId)) {
                String productName = (String) cart.get(productId).get("product_name");
                cart.remove(productId);
                session.setAttribute("message", "Removed " + productName + " from cart");
                session.setAttribute("messageType", "success");
            }

        } else if ("clear".equals(action)) {
            // Clear entire cart
            cart.clear();
            session.setAttribute("message", "Cart cleared");
            session.setAttribute("messageType", "success");
        }

        // Redirect back to products page
        response.sendRedirect("products");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to products page
        response.sendRedirect("products");
    }
}
