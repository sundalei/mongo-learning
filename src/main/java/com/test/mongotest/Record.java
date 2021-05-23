package com.test.mongotest;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@Document(collection = "costs")
public class Record {

    @Id
    public String id;

    private double amount;
    private String category;
    private Date date;
    private String remark;

    public Record() {}

    public Record(double amount, String category, Date date, String remark) {
        this.amount = amount;
        this.category = category;
        this.date = date;
        this.remark = remark;
    }

    public String getId() {
        return id;
    }

    public double getAmount() {
        return amount;
    }

    public String getCategory() {
        return category;
    }

    public Date getDate() {
        return date;
    }

    public String getRemark() {
        return remark;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    @Override
    public String toString() {
        return "Record{" +
                "amount=" + amount +
                ", catagory='" + category + '\'' +
                ", date=" + date +
                ", remark='" + remark + '\'' +
                '}';
    }
}
