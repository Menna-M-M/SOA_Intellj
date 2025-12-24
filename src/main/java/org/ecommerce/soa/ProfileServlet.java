
package org.ecommerce.soa;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Get the ID from the URL parameter (provided by the form)
        String customerId = request.getParameter("customerId");

        // If no ID is provided, go to the input form instead
        if (customerId == null || customerId.isEmpty()) {
            request.getRequestDispatcher("profile_input.jsp").forward(request, response);
            return;
        }

        String apiUrl = "http://localhost:5004/api/customers/" + customerId;
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest apiRequest = HttpRequest.newBuilder()
                .uri(URI.create(apiUrl))
                .GET()
                .build();

        try {
            HttpResponse<String> apiResponse = client.send(apiRequest, HttpResponse.BodyHandlers.ofString());

            if (apiResponse.statusCode() == 200) {
                Gson gson = new Gson();
                Customer customer = gson.fromJson(apiResponse.body(), Customer.class);
                request.setAttribute("customer", customer);
            } else {
                request.setAttribute("error", "Customer ID " + customerId + " not found.");
            }
        } catch (Exception e) {
            request.setAttribute("error", "Service unavailable: Check if Flask is running on port 5004.");
            e.printStackTrace();
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}