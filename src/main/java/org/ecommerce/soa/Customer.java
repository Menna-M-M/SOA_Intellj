package org.ecommerce.soa;

public class Customer {
    private int customer_id;
    private String name;
    private String email;
    private String phone;
    private int loyalty_points;

    public Customer() {}

    // Getters and Setters
    public int getCustomer_id() { return customer_id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public int getLoyalty_points() { return loyalty_points; }

    public void setCustomer_id(int id) { this.customer_id = id; }
    public void setName(String name) { this.name = name; }
    public void setEmail(String email) { this.email = email; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setLoyalty_points(int pts) { this.loyalty_points = pts; }
}