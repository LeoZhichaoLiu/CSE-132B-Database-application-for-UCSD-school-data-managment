<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.Date" %> 
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>schedule review</title>
</head>


<body>
	<jsp:include page="index.html" />
	<table>
	<tr>
	<td>

    <%
    try {
        DriverManager.registerDriver(new org.postgresql.Driver());
    
        Connection conn = DriverManager.getConnection("jdbc:postgresql:leo?user=leo");
        //Connection conn = DriverManager.getConnection(
        //       "jdbc:postgresql:trition?user=postgres&password=Djp7052!");
        
        
        String action = request.getParameter("action");
        String action2 = request.getParameter("action2");
        
        ResultSet class_info = null;
        ResultSet student_info = null;
        int year = 2022;
        String quarter = null;
        int section_id = 0;
        String class_title = null;
        
        int start_month = 0; 
        int end_month = 0; 
        int start_day = 0; 
        int end_day = 0; 
        
        HashSet<String> meeting = new HashSet<>();
        
        
        // Select all class's information
        conn.setAutoCommit(false);
    	PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM class");
    	
    	class_info = pstmt2.executeQuery();
    	conn.commit();
    	conn.setAutoCommit(true);
    	
    	
        // Select all student in class roster
        if (action != null && action.equals("submit")) {
        	
            conn.setAutoCommit(false);
            
            String[] info = request.getParameter("class_information").split(" ");  
            year = Integer.parseInt(info[1]);
            quarter = info[2];
            section_id = Integer.parseInt(info[3]);
            
            PreparedStatement pstmt = null;
            
            if (year == 2022 && quarter.equals("SP")) {
            	
            	pstmt = conn.prepareStatement(
    					"SELECT * FROM student NATURAL JOIN course_enrollment c where c.section_id = ? AND c.course_name = ?"
    			);

                pstmt.setInt(1, section_id);
                pstmt.setString(2, info[0]);
            	
            	
            } else {
            	
            	pstmt = conn.prepareStatement(
					"SELECT * FROM student NATURAL JOIN class_taken_in_the_past c where c.year = ? AND c.quarter = ? AND c.section_id = ? AND c.course_title = ?"
				);
            
           		pstmt.setInt(1, year);
            	pstmt.setString(2, quarter);
            	pstmt.setInt(3, section_id);
            	pstmt.setString(4, info[0]);
        	}
                        
            student_info = pstmt.executeQuery();
     
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        if (action2 != null && action2.equals("submit")) {
        	
        	String[] start = request.getParameter("start").split("-");
        	String[] end = request.getParameter("end").split("-");
        	
        	year = Integer.parseInt(start[0]);
        	start_month = Integer.parseInt(start[1]);
            end_month = Integer.parseInt(end[1]);
            start_day = Integer.parseInt(start[2]);
            end_day = Integer.parseInt(end[2]);   
        }

    %> 

            <%-- presentation --%>
            
            <h2>Choose Class</h2>
			<form action="schedule_review.jsp" method="POST">
		
			<div>
				Class:
				<select name="class_information">
					<%
					if (class_info != null) {
					if (class_info.isBeforeFirst())
					{
						while(class_info.next()){
							String class_information = class_info.getString("course_name") + 
									                  " " + class_info.getString("year") + 
									                  " " + class_info.getString("quarter") +
									                  " " + class_info.getString("section_id") + 
									                  " " + class_info.getString("class_title");
							%>
							<option value="<%=class_information%>"> <%= class_information %> </option>
							<%
						}
					}
					}
					%>
				</select>
			</div>
			
			<button type="submit" name="action" value="submit">Submit</button>
		  </form>	
		  
			<h3>The class you choose is :</h3>
			
			<% 
			if (student_info != null) {
			%>
			   <p> <%=request.getParameter("class_information") %></p>
				
			<% 
			}
			%>
			
			<h2>Choose Date</h2>
			<form action="schedule_review.jsp" method="POST">
			
			<% 
			    if (quarter != null) {
				if (quarter.equals("FA")) {
					String start = year + "-10-01";
					String end = year + "-12-15";
			%>
				Start Date:
   					 <input type="date" name="start" min=<%=start %> max=<%=end %>>
				End Date:
   					 <input type="date" name="end" min=<%=start %> max=<%=end %>>
			<%
				} else if (quarter.equals("WI")) {
					String start = year + "-01-05";
					String end = year + "-03-15";
			%>
				Start Date:
   					 <input type="date" name="start" min=<%=start %> max=<%=end %>>
				End Date:
   					 <input type="date" name="end" min=<%=start %> max=<%=end %>>
			
			<%
				} else {
					String start = year + "-04-01";
					String end = year + "-06-15";
			%>
				Start Date:
   					 <input type="date" name="start" min=<%=start %> max=<%=end %>>
				End Date:
   					 <input type="date" name="end" min=<%=start %> max=<%=end %>>
			
			<%
				}
			    }
			%>
		
			<button type="submit" name="action2" value="submit">Submit</button>
		  </form>		 
	 	 
	 	<%
	 	    // For each student taking that class, we find every meeting of other class they take in same year/quarter
	 	    if (action != null) {
	 	    	pstmt2 = conn.prepareStatement("delete from occupy_time");
				pstmt2.executeUpdate();
	 	    }
			
	  		if (student_info != null) {
	  			if (student_info.isBeforeFirst()) {
					while(student_info.next()) { 
						
					    String student_id = student_info.getString("id");
					    PreparedStatement pstmt = null;
					    
					    if (year == 2022 && quarter.equals("SP")) {
					    	pstmt = conn.prepareStatement(
								"SELECT * FROM course_enrollment NATURAL JOIN weekly_meeting w where w.year = 2022 AND w.quarter = 'SP'"
							);
					    	
					    } else {
					    	pstmt = conn.prepareStatement(
								"SELECT * FROM weekly_meeting where course_name in " +
					            "(SELECT course_title from class_taken_in_the_past c where c.year = ? AND c.quarter = ? AND id = ?) " +
								"AND section_id = ? AND year = ? AND quarter = ?"
							);
					    	pstmt.setInt(1, year);
					        pstmt.setString(2, quarter);				        
					        pstmt.setString(3, student_id);
					        pstmt.setInt(4, section_id);
					        pstmt.setInt(5, year);
					        pstmt.setString(6, quarter);
						}	

				                        
				        ResultSet other_course_info = pstmt.executeQuery();
				        
				        // For every other course's meeting, we record its day(mon-sun) and its time, in hashset.
				        if (other_course_info != null) {
				  			if (other_course_info.isBeforeFirst()) {
								
								while(other_course_info.next()) { 
									String day = other_course_info.getString("day");
									String start_time = other_course_info.getString("start_time");
									String end_time = other_course_info.getString("end_time");	
									
									int start = Integer.parseInt(start_time.split(":")[0]);
									int end = Integer.parseInt(end_time.split(":")[0]);
									
									if (Integer.parseInt(end_time.split(":")[1]) > 0) {
										end++;
									}
									
									
									while (start < end) {
										String full_time = day + "-" + start;
										
										// Insert result into table
								    	pstmt2 = conn.prepareStatement("INSERT INTO occupy_time VALUES (?)");
								    	pstmt2.setString(1, full_time);
								    	
								    	try {
								    		pstmt2.executeUpdate();
								    	} catch (Exception e) {
								    		
								    	}
								    	System.err.println(start);

										start++;
									}	
								}
				  			}
				       }   
					}
				}			  			
	  		}
	 	
	 	%>
	 	<table>
	 	 <tr>
	 	     <th>Available time for review session</th>
	    </tr>
	    
	    <%
	    
	    if (action2 != null) {
	    
	    // If start month and end month are same, we just loop through every day, to check whether given time is valid.
	    if (start_month == end_month) {
	    	for (int i = start_day; i <= end_day; i++) {
	    		
	    		String inputDate = i + "/" + start_month + "/" + year;
	    		SimpleDateFormat format1 = new SimpleDateFormat("dd/MM/yyyy");
	    		Date dt1 = new Date(format1.parse(inputDate).getTime());
	    		DateFormat format2 = new SimpleDateFormat("EEEE", Locale.ENGLISH); 
	    		String day_week = format2.format(dt1);
	    		
	    		if (day_week.equals("Monday")) {
	    			day_week = "Mon";
	    		} else if (day_week.equals("Tuesday")) {
	    			day_week = "Tue";
	    		} else if (day_week.equals("Wednesday")) {
	    			day_week = "Wed";
	    		} else if (day_week.equals("Thursday")) {
	    			day_week = "Thu";
	    		} else if (day_week.equals("Friday")) {
	    			day_week = "Fri";
	    		} else if (day_week.equals("Saturday")) {
	    			day_week = "Sat";
	    		} else if (day_week.equals("Sunday")) {
	    			day_week = "Sun";
	    		}
	    		
	    		for (int j = 8; j < 20; j++) {
	    			String input_time = day_week + "-" + j;
	    			
	    			pstmt2 = conn.prepareStatement("select * from occupy_time where time = ?");
			    	pstmt2.setString(1, input_time);
			    	ResultSet res = pstmt2.executeQuery();
			    	
	    			if (!res.next()) {
	    				String output_time = start_month + "/" + i + "/" + year + " " 
	    			                         + day_week + " " + j + ":00 - " + (j+1) + ":00";
	    				%>
	    				<tr>
					   		<td><%=output_time %></td>
						</tr>
	    				<% 	
	    			}	
	    		}
	    	}
	    } else {
	    	
	    	// If the month are different, we divide into 3 steps to check for valid time. 
			for (int i = start_day; i <= 31; i++) {
	    		
	    		String inputDate = i + "/" + start_month + "/" + year;
	    		SimpleDateFormat format1 = new SimpleDateFormat("dd/MM/yyyy");
	    		Date dt1 = new Date(format1.parse(inputDate).getTime());
	    		DateFormat format2 = new SimpleDateFormat("EEEE"); 
	    		String day_week = format2.format(dt1);
	    		
	    		if (day_week.equals("Monday")) {
	    			day_week = "Mon";
	    		} else if (day_week.equals("Tuesday")) {
	    			day_week = "Tue";
	    		} else if (day_week.equals("Wednesday")) {
	    			day_week = "Wed";
	    		} else if (day_week.equals("Thursday")) {
	    			day_week = "Thu";
	    		} else if (day_week.equals("Friday")) {
	    			day_week = "Fri";
	    		} else if (day_week.equals("Saturday")) {
	    			day_week = "Sat";
	    		} else if (day_week.equals("Sunday")) {
	    			day_week = "Sun";
	    		}
	    		
	    		for (int j = 8; j < 20; j++) {
	    			String input_time = day_week + "-" + j;
	    			
	    			pstmt2 = conn.prepareStatement("select * from occupy_time where time = ?");
			    	pstmt2.setString(1, input_time);
			    	ResultSet res = pstmt2.executeQuery();
	    			
	    			if (!res.next()) {
	    				String output_time = start_month + "/" + i + "/" + year + " " 
	    			                         + day_week + " " + j + ":00 - " + (j+1) + ":00";
	    				%>
	    				<tr>
					   		<td><%=output_time %></td>
						</tr>
	    				<% 	
	    			}	
	    		}
	    	}
			
			for (int m = start_month+1; m < end_month; m ++) {
				for (int i = 1; i <= 31; i++) {
	    		
	    			String inputDate = i + "/" + m + "/" + year;
	    			SimpleDateFormat format1 = new SimpleDateFormat("dd/MM/yyyy");
	    			Date dt1 = new Date(format1.parse(inputDate).getTime());
	    			DateFormat format2 = new SimpleDateFormat("EEEE"); 
	    			String day_week = format2.format(dt1);
	    			
	    			if (day_week.equals("Monday")) {
		    			day_week = "Mon";
		    		} else if (day_week.equals("Tuesday")) {
		    			day_week = "Tue";
		    		} else if (day_week.equals("Wednesday")) {
		    			day_week = "Wed";
		    		} else if (day_week.equals("Thursday")) {
		    			day_week = "Thu";
		    		} else if (day_week.equals("Friday")) {
		    			day_week = "Fri";
		    		} else if (day_week.equals("Saturday")) {
		    			day_week = "Sat";
		    		} else if (day_week.equals("Sunday")) {
		    			day_week = "Sun";
		    		}
	    		
	    			for (int j = 8; j < 20; j++) {
	    				String input_time = day_week + "-" + j;
	    				
	    				pstmt2 = conn.prepareStatement("select * from occupy_time where time = ?");
				    	pstmt2.setString(1, input_time);
				    	ResultSet res = pstmt2.executeQuery();
				    	
	    				if (!res.next()) {
	    					String output_time = m + "/" + i + "/" + year + " " 
	    			                         + day_week + " " + j + ":00 - " + (j+1) + ":00";
	    					%>
	    					<tr>
					   			<td><%=output_time %></td>
							</tr>
	    					<% 	
	    				}	
	    			}
	    		}
			}
			
			for (int i = 1; i <= end_day; i++) {
	    		
	    		String inputDate = i + "/" + end_month + "/" + year;
	    		SimpleDateFormat format1 = new SimpleDateFormat("dd/MM/yyyy");
	    		Date dt1 = new Date(format1.parse(inputDate).getTime());
	    		DateFormat format2 = new SimpleDateFormat("EEEE"); 
	    		String day_week = format2.format(dt1);
	    		
	    		if (day_week.equals("Monday")) {
	    			day_week = "Mon";
	    		} else if (day_week.equals("Tuesday")) {
	    			day_week = "Tue";
	    		} else if (day_week.equals("Wednesday")) {
	    			day_week = "Wed";
	    		} else if (day_week.equals("Thursday")) {
	    			day_week = "Thu";
	    		} else if (day_week.equals("Friday")) {
	    			day_week = "Fri";
	    		} else if (day_week.equals("Saturday")) {
	    			day_week = "Sat";
	    		} else if (day_week.equals("Sunday")) {
	    			day_week = "Sun";
	    		}
	    		
	    		
	    		for (int j = 8; j < 20; j++) {
	    			String input_time = day_week + "-" + j;
	    			
	    			pstmt2 = conn.prepareStatement("select * from occupy_time where time = ?");
			    	pstmt2.setString(1, input_time);
			    	ResultSet res = pstmt2.executeQuery();
			    	
	    			if (!res.next()) {
	    				String output_time = end_month + "/" + i + "/" + year + " " 
	    			                         + day_week + " " + j + ":00 - " + (j+1) + ":00";
	    				%>
	    				<tr>
					   		<td><%=output_time %></td>
						</tr>
	    				<% 	
	    			}	
	    		}
	    	}	
	    }
	    }
	    %>
	
	  </table>
	
     <%-- iteration --%>        
     
     <%
      conn.close();
           
      } catch (SQLException e1) {
    	  throw new RuntimeException("SQL Exception!", e1); 
    	  
      } catch (Exception e2) {
    	  throw new RuntimeException("Exception!", e2); 
      }
      %>
      
     </td>
     </tr>
     </table>

</body>
</html>