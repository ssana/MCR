package com.visa.web.service;
import javax.jws.WebService;

import org.sqlite.SQLiteDataSource;
import org.sqlite.SQLiteJDBCLoader;

import java.sql.ResultSet;
import java.sql.SQLException;

@WebService

public class RatingWebService {

	public String getRating(String merchantName, String location)
	{
		try
		{
			
			Class.forName("org.sqlite.JDBC");
	        SQLiteJDBCLoader.initialize();

	        SQLiteDataSource dataSource = new SQLiteDataSource();
	        dataSource.setUrl("jdbc:sqlite:"+RunService.databaseName);
			ResultSet rs = dataSource.getConnection().createStatement().executeQuery( "select RATING from merchant_rating where merch_name = \'" + merchantName + "\' AND location = \'" + location + "\'" );
			if(rs.next())
			{
				return ""+rs.getDouble("RATING");
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
