package org.ecommerce.soa;

import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    private static final String INVENTORY_API_URL = "http://localhost:5002/api/inventory/products";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== ProductServlet: doGet called ===");

        try {
            // Call the inventory API
            System.out.println("Calling API: " + INVENTORY_API_URL);
            URL url = new URL(INVENTORY_API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Accept", "application/json");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);

            int responseCode = conn.getResponseCode();
            System.out.println("API Response Code: " + responseCode);

            if (responseCode == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(
                        new InputStreamReader(conn.getInputStream())
                );
                String inputLine;
                StringBuilder content = new StringBuilder();

                while ((inputLine = in.readLine()) != null) {
                    content.append(inputLine);
                }

                in.close();
                conn.disconnect();

                String jsonResponse = content.toString();
                System.out.println("API Response: " + jsonResponse);

                // Parse JSON response
                Gson gson = new Gson();
                List<Product> products = gson.fromJson(
                        jsonResponse,
                        new TypeToken<List<Product>>(){}.getType()
                );

                System.out.println("Parsed " + (products != null ? products.size() : 0) + " products");

                if (products != null) {
                    for (Product p : products) {
                        System.out.println("Product: " + p.getProduct_name() + " - $" + p.getUnit_price());
                    }
                }

                // Set products as request attribute
                request.setAttribute("products", products);

                // Forward to JSP
                System.out.println("Forwarding to index.jsp");
                request.getRequestDispatcher("/index.jsp").forward(request, response);

            } else {
                System.out.println("API call failed with code: " + responseCode);
                request.setAttribute("error", "Failed to fetch products from inventory API (Code: " + responseCode + ")");
                request.setAttribute("products", new ArrayList<Product>());
                request.getRequestDispatcher("/index.jsp").forward(request, response);
            }

        } catch (Exception e) {
            System.out.println("Exception occurred: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.setAttribute("products", new ArrayList<Product>());
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }

    // Inner class to represent Product
    public static class Product {
        private int product_id;
        private String product_name;
        private int quantity_available;
        private double unit_price;

        // Getters and Setters
        public int getProduct_id() {
            return product_id;
        }

        public void setProduct_id(int product_id) {
            this.product_id = product_id;
        }

        public String getProduct_name() {
            return product_name;
        }

        public void setProduct_name(String product_name) {
            this.product_name = product_name;
        }

        public int getQuantity_available() {
            return quantity_available;
        }

        public void setQuantity_available(int quantity_available) {
            this.quantity_available = quantity_available;
        }

        public double getUnit_price() {
            return unit_price;
        }

        public void setUnit_price(double unit_price) {
            this.unit_price = unit_price;
        }
    }
}