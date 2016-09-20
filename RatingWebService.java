package com.visa.web.service;
import javax.jws.WebService;

import org.sqlite.SQLiteDataSource;
import org.sqlite.SQLiteJDBCLoader;

import java.sql.ResultSet;
import java.sql.SQLException;

@WebService

public class RatingWebService {

	public String getRating(String merchantName)
	{
		try
		{
			
			Class.forName("org.sqlite.JDBC");
	        SQLiteJDBCLoader.initialize();

	        SQLiteDataSource dataSource = new SQLiteDataSource();
	        dataSource.setUrl("jdbc:sqlite:"+RunService.databaseName);
			ResultSet rs = dataSource.getConnection().createStatement().executeQuery( "select * from Merchant_rating where MerchantName = \'" + merchantName.toUpperCase() + "\'" );
			if(rs.next())
			{
				String output = "<SalesCount>" + rs.getInt("SalesCount") + "</SalesCount>\n";
				output = output + "<ChargebacksCount>" + rs.getInt("ChargebacksCount") + "</ChargebacksCount>\n";
				output = output + "<RefundsCount>" + rs.getInt("RefundsCount") + "</RefundsCount>\n";
				output = output + "<RepresentmentsCount>" + rs.getInt("RepresentmentsCount") + "</RepresentmentsCount>\n";
				output = output + "<Score>" + rs.getDouble("Score") + "</Score>\n";
				return output;
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "-1.0";
	}
}
