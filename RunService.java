package com.visa.web.service;

import javax.xml.ws.Endpoint;

public class RunService {

	/**
	 * @param args
	 */

	public static String databaseName = null;
	

	public static void main(String[] args) throws Exception {

		databaseName = args[0];
		
		System.out.println("Rating Web Service about to start.");
		Endpoint.publish("http://localhost:8080/ratingWebService", new RatingWebService());
	}
}
