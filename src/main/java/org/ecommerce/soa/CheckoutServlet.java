package org.ecommerce.soa;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.OutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.*;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        @SuppressWarnings("unchecked")
        Map<String, Map<String, Object>> cart =
                (Map<String, Map<String, Object>>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("products");
            return;
        }

        // Build pricing request
        List<Map<String, Object>> items = new ArrayList<>();
        double subtotal = 0.0;

        for (Map<String, Object> item : cart.values()) {
            int quantity = (Integer) item.get("quantity");
            int product_id = Integer.parseInt(item.get("product_id").toString());

            Map<String, Object> product = new HashMap<>();
            product.put("product_id", product_id);
            product.put("quantity", quantity);

            items.add(product);
        }

        Map<String, Object> pricingRequest = new HashMap<>();
        pricingRequest.put("products", items);

        String jsonRequest = gson.toJson(pricingRequest);

        // Call Pricing Service
        URL url = new URL("http://localhost:5003/api/pricing/calculate");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonRequest.getBytes(StandardCharsets.UTF_8));
        }

        Map<String, Object> pricingResponse;

        if (conn.getResponseCode() == 200) {
            pricingResponse = gson.fromJson(
                    new InputStreamReader(conn.getInputStream()),
                    new TypeToken<Map<String, Object>>() {}.getType()
            );
        } else {
            pricingResponse = new HashMap<>();
            pricingResponse.put("tax", 0.0);
            pricingResponse.put("discount", 0.0);
            pricingResponse.put("total", subtotal);
        }
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> pricedItems =
                (List<Map<String, Object>>) pricingResponse.get("items");

        // Send item-level details to JSP
        request.setAttribute("pricedItems", pricedItems);
        // Send values to JSP
        request.setAttribute("subtotal", pricingResponse.get("subtotal"));
        request.setAttribute("tax_rate", pricingResponse.get("tax_rate"));
        request.setAttribute("tax", pricingResponse.get("tax"));
        request.setAttribute("discount", pricingResponse.get("total_discount"));
        request.setAttribute("finalTotal", pricingResponse.get("grand_total"));
        request.getRequestDispatcher("checkout.jsp").forward(request, response);
    }

    // ✅ FIX FOR 405 ERROR
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
