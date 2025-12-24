package org.ecommerce.soa;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/submitOrder")
public class OrderServlet extends HttpServlet {

    private static final String ORDER_API_URL = "http://127.0.0.1:5001/api/orders/create";
    private static final String CUSTOMER_LOYALTY_URL = "http://127.0.0.1:5004/api/customers/%d/loyalty";
    private static final String NOTIFICATION_API_URL = "http://127.0.0.1:5005/api/notifications/send";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Gson gson = new Gson();

        try {
            // 1. Get customer information
            String customerId = request.getParameter("customer_id");
            String totalAmount = request.getParameter("total_amount");

            System.out.println("=== Order Submission Started ===");
            System.out.println("Customer ID: " + customerId);
            System.out.println("Total Amount: " + totalAmount);

            if (customerId == null || totalAmount == null || customerId.trim().isEmpty()) {
                session.setAttribute("message", "Missing customer or total amount information");
                session.setAttribute("messageType", "error");
                response.sendRedirect("checkout");
                return;
            }

            // 2. Get product count and build products array
            String productCountStr = request.getParameter("product_count");

            if (productCountStr == null) {
                session.setAttribute("message", "No products in order");
                session.setAttribute("messageType", "error");
                response.sendRedirect("checkout");
                return;
            }

            int productCount = Integer.parseInt(productCountStr);
            System.out.println("Product Count: " + productCount);

            List<Map<String, Object>> products = new ArrayList<>();

            for (int i = 0; i < productCount; i++) {
                String productId = request.getParameter("product_id_" + i);
                String quantity = request.getParameter("quantity_" + i);

                System.out.println("Product " + i + ": ID=" + productId + ", Quantity=" + quantity);

                if (productId != null && quantity != null) {
                    Map<String, Object> product = new HashMap<>();
                    product.put("product_id", Integer.parseInt(productId));
                    product.put("quantity", Integer.parseInt(quantity));
                    products.add(product);
                }
            }

            if (products.isEmpty()) {
                session.setAttribute("message", "No products in order");
                session.setAttribute("messageType", "error");
                response.sendRedirect("checkout");
                return;
            }

            // 3. Build JSON payload for Order Service
            Map<String, Object> orderData = new HashMap<>();
            orderData.put("customer_id", Integer.parseInt(customerId));
            orderData.put("total_amount", Double.parseDouble(totalAmount));
            orderData.put("products", products);
            orderData.put("region", "Egypt");

            String jsonPayload = gson.toJson(orderData);
            System.out.println("Sending to Order Service: " + jsonPayload);

            // 4. Call Order Service API
            String orderResponseBody = callOrderService(jsonPayload);

            if (orderResponseBody == null) {
                session.setAttribute("message", "Order Service failed. Please try again.");
                session.setAttribute("messageType", "error");
                response.sendRedirect("checkout");
                return;
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> orderResponse = gson.fromJson(orderResponseBody, Map.class);
            String orderId = orderResponse.get("order_id").toString();

            System.out.println("Order created successfully! Order ID: " + orderId);

            // 5. Calculate and update loyalty points (1 point per 10 EGP)
            double totalValue = Double.parseDouble(totalAmount);
            int loyaltyPoints = (int) Math.floor(totalValue / 10);

            System.out.println("Updating loyalty points: " + loyaltyPoints);
            boolean loyaltyUpdated = updateLoyaltyPoints(customerId, loyaltyPoints);

            // 6. Send notification email
            System.out.println("Sending notification...");
            boolean notificationSent = sendNotification(orderId, customerId, products, totalAmount);

            // 7. Clear cart and store order details
            session.removeAttribute("cart");
            session.removeAttribute("pricingBreakdown");

            session.setAttribute("orderSuccess", true);
            session.setAttribute("orderId", orderId);
            session.setAttribute("orderTotal", totalAmount);
            session.setAttribute("customerId", customerId);
            session.setAttribute("orderResponse", orderResponse);
            session.setAttribute("loyaltyPointsEarned", loyaltyPoints);
            session.setAttribute("loyaltyUpdated", loyaltyUpdated);
            session.setAttribute("notificationSent", notificationSent);

            // 8. Redirect to confirmation page
            response.sendRedirect("confirmations.jsp");

        } catch (NumberFormatException e) {
            System.out.println("Number format error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("message", "Invalid number format in order data");
            session.setAttribute("messageType", "error");
            response.sendRedirect("checkout");

        } catch (Exception e) {
            System.out.println("Error processing order: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("message", "Error processing order: " + e.getMessage());
            session.setAttribute("messageType", "error");
            response.sendRedirect("checkout");
        }
    }

    // Helper method to call Order Service
    private String callOrderService(String jsonPayload) {
        try {
            URL url = new URL(ORDER_API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(30000);
            conn.setReadTimeout(30000);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            System.out.println("Order Service Response Code: " + responseCode);

            BufferedReader in;
            if (responseCode >= 200 && responseCode < 300) {
                in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            } else {
                in = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            }

            StringBuilder content = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                content.append(inputLine);
            }
            in.close();
            conn.disconnect();

            String responseBody = content.toString();
            System.out.println("Order Service Response: " + responseBody);

            if (responseCode == HttpURLConnection.HTTP_OK || responseCode == 201) {
                return responseBody;
            }
            return null;

        } catch (Exception e) {
            System.out.println("Error calling Order Service: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    // Helper method to update loyalty points
    private boolean updateLoyaltyPoints(String customerId, int points) {
        try {
            String loyaltyUrl = String.format(CUSTOMER_LOYALTY_URL, Integer.parseInt(customerId));

            Map<String, Object> loyaltyData = new HashMap<>();
            loyaltyData.put("points", points);

            Gson gson = new Gson();
            String jsonPayload = gson.toJson(loyaltyData);

            System.out.println("Calling Customer Service: " + loyaltyUrl);
            System.out.println("Payload: " + jsonPayload);

            URL url = new URL(loyaltyUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("PUT");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            System.out.println("Customer Service Response Code: " + responseCode);

            conn.disconnect();

            return responseCode == 200;

        } catch (Exception e) {
            System.out.println("Error updating loyalty points: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Helper method to send notification
    private boolean sendNotification(String orderId, String customerId,
                                     List<Map<String, Object>> products, String totalAmount) {
        try {
            Map<String, Object> notificationData = new HashMap<>();
            notificationData.put("order_id", orderId);
            notificationData.put("customer_id", Integer.parseInt(customerId));
            notificationData.put("products", products);
            notificationData.put("total_amount", Double.parseDouble(totalAmount));

            Gson gson = new Gson();
            String jsonPayload = gson.toJson(notificationData);

            System.out.println("Calling Notification Service");
            System.out.println("Payload: " + jsonPayload);

            URL url = new URL(NOTIFICATION_API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            System.out.println("Notification Service Response Code: " + responseCode);

            BufferedReader in = new BufferedReader(
                    new InputStreamReader(conn.getInputStream())
            );
            StringBuilder content = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                content.append(inputLine);
            }
            in.close();
            conn.disconnect();

            System.out.println("Notification Response: " + content.toString());

            return responseCode == 200;

        } catch (Exception e) {
            System.out.println("Error sending notification: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}