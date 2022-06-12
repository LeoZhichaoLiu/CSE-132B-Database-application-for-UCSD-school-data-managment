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
	<title>Class Entry</title>
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
        
        
        PreparedStatement trigger_stmt = conn.prepareStatement(
      		  "CREATE OR REPLACE FUNCTION prof_function() RETURNS TRIGGER AS $$ " +
                "BEGIN " +
      		  "if ((select valid from prof_time) = false)" +
      	      "then raise exception 'There are conflicts of your time'; " + 
      	      "end if;" +
      	      "return new; " + 
      	      "end; $$ language plpgsql;" +
      	      "CREATE OR REPLACE TRIGGER prof_constraint BEFORE INSERT or UPDATE ON Review FOR EACH ROW EXECUTE PROCEDURE prof_function();"
        );
        trigger_stmt.executeUpdate();
        
        
        String action = request.getParameter("action");
        
        // Insertion entries to database
        if (action != null && action.equals("insert")) {
        	
            conn.setAutoCommit(false);
            
            // Get all data from course and time.
            String course_id = request.getParameter("Course_id");
            String[] id_array = course_id.split(" ");
            
            String course_name = id_array[0];
            int section_id =  Integer.parseInt(id_array[1]);
            int year = Integer.parseInt(id_array[2]);
            String quarter = id_array[3];
            
            String[] start_array = request.getParameter("Start_Time").split(":");
            int start_h = Integer.parseInt(start_array[0]);
            int start_m = Integer.parseInt(start_array[1]);
            
            String[] end_array = request.getParameter("End_Time").split(":");
            int end_h = Integer.parseInt(end_array[0]);
            int end_m = Integer.parseInt(end_array[1]);
            
            // Get the information of data nad the day of the week
            String full_date = request.getParameter("Date");
            String month = full_date.split("/")[0];
            String date = full_date.split("/")[1];
            
            String inputDate = date + "/" + month + "/" + year;
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
            
            
            // First, we try to get all data that may have conflict from weekly meeting.
            PreparedStatement prof_courses = conn.prepareStatement(
          		  "SELECT * from weekly_meeting NATURAL JOIN class " +  
                    "where class.instructor = (select instructor from class where course_name = ? and " + 
                    "section_id = ? and year = ? and quarter = ?) and " +
                    "weekly_meeting.day = ? " + 
                    "and class.year = ? and class.quarter = ?;" 
          		  
            );
            prof_courses.setString(1, course_name);
            prof_courses.setInt(2, section_id);
            prof_courses.setInt(3, year);
            prof_courses.setString(4, quarter);
            prof_courses.setString(5, day_week);
            prof_courses.setInt(6, year);
            prof_courses.setString(7, quarter);
            
            ResultSet prof_rs = prof_courses.executeQuery();
            
            boolean valid = true;
            
            while (prof_rs.next()) {
  
          	  int start_h1 = prof_rs.getInt("start_h");
          	  int start_m1 = prof_rs.getInt("start_m");
          	  int end_h1 = prof_rs.getInt("end_h");
          	  int end_m1 = prof_rs.getInt("end_m");
          	  
          	  if (((( (start_h == end_h1) && (start_m <= end_m1)) || (start_h < end_h1)) &&  
                 	 (( (end_h == start_h1) && (end_m >= start_m1)) || (end_h > start_h1)))) {

          		  valid = false;
                    break;
          	  } 
            }
            
            // Then, we try to select all data that may conflict from other's review section.
            prof_courses = conn.prepareStatement(
            		  "SELECT * from Review NATURAL JOIN class " +  
                      "where class.instructor = (select instructor from class where course_name = ? and " + 
                      "section_id = ? and year = ? and quarter = ?) and " +
                      "review.date = ? " + 
                      "and class.year = ? and class.quarter = ?;" 
            		  
              );
              prof_courses.setString(1, course_name);
              prof_courses.setInt(2, section_id);
              prof_courses.setInt(3, year);
              prof_courses.setString(4, quarter);
              prof_courses.setString(5, full_date);
              prof_courses.setInt(6, year);
              prof_courses.setString(7, quarter);
              
              prof_rs = prof_courses.executeQuery();
              
              while (prof_rs.next()) {
    
            	  int start_h1 = prof_rs.getInt("start_h");
            	  int start_m1 = prof_rs.getInt("start_m");
            	  int end_h1 = prof_rs.getInt("end_h");
            	  int end_m1 = prof_rs.getInt("end_m");
            	  
            	  if (((( (start_h == end_h1) && (start_m <= end_m1)) || (start_h < end_h1)) &&  
                   	 (( (end_h == start_h1) && (end_m >= start_m1)) || (end_h > start_h1)))) {

            		  valid = false;
                      break;
            	  } 
              }
              
              // Update the whether these dates are conflicts in the intermedia table
              PreparedStatement valid_stmt = conn.prepareStatement("update prof_time set valid = ?");
              valid_stmt.setBoolean(1, valid);
              valid_stmt.executeUpdate();
            

              
            // If passed the trigger, then we can insert the data into Review section.
            PreparedStatement stmt_review = conn.prepareStatement(
                "INSERT INTO Review VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
  
            stmt_review.setString(1, course_name);
            stmt_review.setInt(2, section_id);
            stmt_review.setInt(3, year);
            stmt_review.setString(4, quarter);
            
            stmt_review.setString(5, full_date);
            stmt_review.setString(6, request.getParameter("Start_Time"));
            stmt_review.setString(7, request.getParameter("End_Time"));
            stmt_review.setString(8, request.getParameter("Building"));
            stmt_review.setString(9, request.getParameter("Room"));
    		
    		stmt_review.setString(10, day_week);
    		stmt_review.setInt(11, start_h);
    		stmt_review.setInt(12, start_m);
    		stmt_review.setInt(13, end_h);
    		stmt_review.setInt(14, end_m);
    		
            stmt_review.executeUpdate();
           
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        // Update entries to databbase
        if (action != null && action.equals("update")) {
        	
           
            conn.setAutoCommit(false);
            
            
            // Get all data from course and time.
            String course_id = request.getParameter("Course_id");
            String[] id_array = course_id.split(" ");
            
            String course_name = id_array[0];
            int section_id =  Integer.parseInt(id_array[1]);
            int year = Integer.parseInt(id_array[2]);
            String quarter = id_array[3];
            
            String[] start_array = request.getParameter("Start_Time").split(":");
            int start_h = Integer.parseInt(start_array[0]);
            int start_m = Integer.parseInt(start_array[1]);
            
            String[] end_array = request.getParameter("End_Time").split(":");
            int end_h = Integer.parseInt(end_array[0]);
            int end_m = Integer.parseInt(end_array[1]);
            
            // Get the information of data nad the day of the week
            String full_date = request.getParameter("Date");
            String month = full_date.split("/")[0];
            String date = full_date.split("/")[1];
            
            String inputDate = date + "/" + month + "/" + year;
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
            
            
            // First, we try to get all data that may have conflict from weekly meeting.
            PreparedStatement prof_courses = conn.prepareStatement(
          		  "SELECT * from weekly_meeting NATURAL JOIN class " +  
                    "where class.instructor = (select instructor from class where course_name = ? and " + 
                    "section_id = ? and year = ? and quarter = ?) and " +
                    "weekly_meeting.day = ? " + 
                    "and class.year = ? and class.quarter = ?;" 
          		  
            );
            prof_courses.setString(1, course_name);
            prof_courses.setInt(2, section_id);
            prof_courses.setInt(3, year);
            prof_courses.setString(4, quarter);
            prof_courses.setString(5, day_week);
            prof_courses.setInt(6, year);
            prof_courses.setString(7, quarter);
            
            ResultSet prof_rs = prof_courses.executeQuery();
            
            boolean valid = true;
            
            while (prof_rs.next()) {
  
          	  int start_h1 = prof_rs.getInt("start_h");
          	  int start_m1 = prof_rs.getInt("start_m");
          	  int end_h1 = prof_rs.getInt("end_h");
          	  int end_m1 = prof_rs.getInt("end_m");
          	  
          	  if (((( (start_h == end_h1) && (start_m <= end_m1)) || (start_h < end_h1)) &&  
                 	 (( (end_h == start_h1) && (end_m >= start_m1)) || (end_h > start_h1)))) {

          		  valid = false;
                    break;
          	  } 
            }
            
            // Then, we try to select all data that may conflict from other's review section.
            prof_courses = conn.prepareStatement(
            		  "SELECT * from Review NATURAL JOIN class " +  
                      "where class.instructor = (select instructor from class where course_name = ? and " + 
                      "section_id = ? and year = ? and quarter = ?) and " +
                      "review.date = ? " + 
                      "and class.year = ? and class.quarter = ?;" 
            		  
              );
              prof_courses.setString(1, course_name);
              prof_courses.setInt(2, section_id);
              prof_courses.setInt(3, year);
              prof_courses.setString(4, quarter);
              prof_courses.setString(5, full_date);
              prof_courses.setInt(6, year);
              prof_courses.setString(7, quarter);
              
              prof_rs = prof_courses.executeQuery();
              
              
              while (prof_rs.next()) {
            	  
            	  // If facing the same review meeting, just ignore it
            	  if (prof_rs.getString("course_name").equals(course_name) 
                     	 && prof_rs.getInt("section_id") == section_id ) {
                     		continue;  
                   }
    
            	  int start_h1 = prof_rs.getInt("start_h");
            	  int start_m1 = prof_rs.getInt("start_m");
            	  int end_h1 = prof_rs.getInt("end_h");
            	  int end_m1 = prof_rs.getInt("end_m");
            	  
            	  if (((( (start_h == end_h1) && (start_m <= end_m1)) || (start_h < end_h1)) &&  
                   	 (( (end_h == start_h1) && (end_m >= start_m1)) || (end_h > start_h1)))) {

            		  valid = false;
                      break;
            	  } 
              }
              
              // Update the whether these dates are conflicts in the intermedia table
              PreparedStatement valid_stmt = conn.prepareStatement("update prof_time set valid = ?");
              valid_stmt.setBoolean(1, valid);
              valid_stmt.executeUpdate();
              
              
            // If pass the trigger, we update the new review information.
            PreparedStatement stmt_review = conn.prepareStatement(
                "UPDATE Review SET Start_Time = ?, End_Time = ?, Building = ?, Room = ?, start_h = ?, start_m = ?, " + 
                "end_h = ?, end_m = ? WHERE Course_Name = ? AND Section_id = ? AND Year = ? AND Quarter = ? " +
                "AND Date = ?");
            
            stmt_review.setString(1, request.getParameter("Start_Time"));
            stmt_review.setString(2, request.getParameter("End_Time"));
            stmt_review.setString(3, request.getParameter("Building"));
            stmt_review.setString(4, request.getParameter("Room"));
            
            stmt_review.setInt(5, start_h);
            stmt_review.setInt(6, start_m);
            stmt_review.setInt(7, end_h);
            stmt_review.setInt(8, end_m);
            
            
            stmt_review.setString(9, course_name);
            stmt_review.setInt(10, section_id);
            stmt_review.setInt(11, year);
            stmt_review.setString(12, quarter);
            
            stmt_review.setString(13, request.getParameter("Date"));
         
            
            stmt_review.executeUpdate();
            
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        
        // Delete entries from databse
        if (action != null && action.equals("delete")) {
            
            conn.setAutoCommit(false);
            
            PreparedStatement stmt_review = conn.prepareStatement(
            	"DELETE FROM Review WHERE Course_Name = ? AND Section_id = ? AND Year = ? " +
                "AND Quarter = ? AND Date = ?");
            
            String course_id = request.getParameter("Course_id");
            String[] id_array = course_id.split(" ");
            
            stmt_review.setString(1, id_array[0]);
            stmt_review.setInt(2, Integer.parseInt(id_array[1]));
            stmt_review.setInt(3, Integer.parseInt(id_array[2]));
            stmt_review.setString(4, id_array[3]);
            
            stmt_review.setString(5, request.getParameter("Date"));
            
            int rowCount = stmt_review.executeUpdate();
            
            conn.commit();
            conn.setAutoCommit(true);
        }
    %>
    
     
     <%      
           Statement statement = conn.createStatement();        
           ResultSet rs = statement.executeQuery ("SELECT * FROM Review");
           
     %>     
     
     <table>
         <tr>
               <th>Class_info</th>
               <th>Date</th>
               <th>Start_Time</th>
               <th>End_Time</th>
               <th>Building</th>
               <th>Room</th>
         </tr>
         
         <tr>
               <form action="Review.jsp" method="get">
                   <input type="hidden" value="insert" name="action">
					<%
                   	   Statement statement2 = conn.createStatement();        
                       ResultSet rs2 = statement2.executeQuery ("select * from class");
                    %>
                   <th>
                   		<select name="Course_id">
                   			<%   while (rs2.next()) {   
                   				 String course_name = rs2.getString("Course_Name");
                   				 int section_id = rs2.getInt("Section_id");
                   				 int course_year = rs2.getInt("Year");
                   				 String course_quarter = rs2.getString("Quarter");
                   				 
                   				 String course_id = course_name + " " + section_id + " " + 
                   				                    course_year + " " + course_quarter;
                   			%>
  								<option value="<%= course_id%>"><%= course_id%></option>
  							<%  }  %>
						</select>
                   </th>
                   
                   <th><input value="" name="Date" size="10"></th>
                   <th><input value="" name="Start_Time" size="10"></th>
                   <th><input value="" name="End_Time" size="10"></th>
                   <th><input value="" name="Building" size="10"></th>
                   <th><input value="" name="Room" size="10"></th>
                   <th><input type="submit" value="Insert"></th>
               </form>
         </tr>
           
     <%   
           // Looping every entries in review database, and update the information to table.
           while (rs.next()) {
     %>
    	  <tr>
             <form action="Review.jsp" method="get">
                <input type="hidden" value="update" name="action">

                   <%
                   	   Statement statement3 = conn.createStatement();        
                       ResultSet rs3 = statement3.executeQuery ("select * from class");
                    %>
                   <th>
                   		<select name="Course_id">
                   		
                   			<% 
                   				 String course_name2 = rs.getString("Course_Name");
                   				 int section_id2 = rs.getInt("Section_id");
                   				 int course_year2 = rs.getInt("Year");
                   				 String course_quarter2 = rs.getString("Quarter");
                   				 
                   				 String course_id2 = course_name2 + " " + section_id2 + " " + 
                   				                    course_year2 + " " + course_quarter2;
                   			%>
                   			<option value="<%= course_id2 %>"> <%= course_id2 %></option>
        
                   			<%   while (rs3.next()) {   
                   				
                   				 String course_name = rs3.getString("Course_Name");
                   				 int section_id = rs3.getInt("Section_id");
                   				 int course_year = rs3.getInt("Year");
                   				 String course_quarter = rs3.getString("Quarter");
                   				 
                   				 String course_id = course_name + " " + section_id + " " + 
                   				                    course_year + " " + course_quarter;
                   			%>
  								<option value="<%= course_id%>"><%= course_id%></option>
  							<%  }  %>
						</select>
                  </th>
                <td>
                   <input value="<%= rs.getString("Date") %>"
                    name="Date" size="10">
                </td>
                <td>
                    <input value="<%= rs.getString("Start_Time") %>" 
                    name="Start_Time" size="10">
                 </td>
                 <td>
                    <input value="<%= rs.getString("End_Time") %>" 
                    name="End_Time" size="10">
                 </td>
                 <td>
                    <input value="<%= rs.getString("Building") %>" 
                    name="Building" size="10">
                 </td> 
                 <td>
                    <input value="<%= rs.getString("Room") %>" 
                    name="Room" size="10">
                 </td>          
                 <td>
                    <input type="submit" value="Update">
                 </td>
             </form>
             
             
             <form action="Review.jsp" method="get">
                 <input type="hidden" value="delete" name="action">
                 
                 <input type="hidden" value="<%= course_id2 %>" 
                 name="Course_id">
                 
                 <input type="hidden" value="<%= rs.getString("Date") %>" 
                 name="Date">
                 <td>
                     <input type="submit" value="Delete">
                 </td>
              </form>
        </tr>
      
     <% 	  	   	   
           }
     %>
     
     </table>
     
     <%
           rs.close();
           statement.close();
           conn.close();
           
      } catch (SQLException e1) {
    	  out.println (e1.getMessage()); 
    	  
      } catch (Exception e2) {
    	  out.println(e2.getMessage());
      }
      %>
      
     </td>
     </tr>
     </table>

</body>
</html>