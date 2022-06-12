<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Weekly Meeting</title>
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
        
        String action = request.getParameter("action");
        
        conn.setAutoCommit(false);  
        // Use trigger to set constraint based on other weekly meeting for the same class. Cannot overlapped. 
        PreparedStatement trigger_stmt = conn.prepareStatement(
         		 "CREATE OR REPLACE FUNCTION week_function() RETURNS TRIGGER AS $$ " +
                 "DECLARE " +  
         		 "start_h1 weekly_meeting.start_h%type; start_m1 weekly_meeting.start_m%type; " +
                 "end_h1 weekly_meeting.end_h%type; end_m1 weekly_meeting.end_m%type;" +
           	      "BEGIN " +
                 "select start_h into start_h1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Lecture'; " +
                 "select start_m into start_m1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Lecture'; " +
                 "select end_h into end_h1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Lecture'; " +
                 "select end_m into end_m1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Lecture'; " +
                 "if ((( (new.start_h = end_h1) and (new.start_m <= end_m1)) or (new.start_h < end_h1)) and " + 
           	      "(( (new.end_h = start_h1) and (new.end_m >= start_m1)) or (new.end_h > start_h1) ))" +
         		  "then raise exception 'There are conflicts of your time'; " + 
         		  "end if;" +
         		 "select start_h into start_h1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Discussion'; " +
                 "select start_m into start_m1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Discussion'; " +
                 "select end_h into end_h1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Discussion'; " +
                 "select end_m into end_m1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Discussion'; " +
                 "if ((( (new.start_h = end_h1) and (new.start_m <= end_m1)) or (new.start_h < end_h1)) and " + 
           	      "(( (new.end_h = start_h1) and (new.end_m >= start_m1)) or (new.end_h > start_h1) ))" +
         		  "then raise exception 'There are conflicts of your time'; " + 
         		  "end if;" +
         		 "select start_h into start_h1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Lab'; " +
                 "select start_m into start_m1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Lab'; " +
                 "select end_h into end_h1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Lab'; " +
                 "select end_m into end_m1 from weekly_meeting where course_name = new.course_name and section_id = new.section_id and day = new.day and year = new.year and quarter = new.quarter and type != new.type and type = 'Lab'; " +
                 "if ((( (new.start_h = end_h1) and (new.start_m <= end_m1)) or (new.start_h < end_h1)) and " + 
           	      "(( (new.end_h = start_h1) and (new.end_m >= start_m1)) or (new.end_h > start_h1) ))" +
         		  "then raise exception 'There are conflicts of your time'; " + 
         		  "end if;" +
         		  "return new;" + 
         		  "end; $$ language plpgsql;" +
         		  "CREATE OR REPLACE TRIGGER week_constraint BEFORE INSERT or UPDATE ON weekly_meeting FOR EACH ROW EXECUTE PROCEDURE week_function();"
          );
          
          trigger_stmt.executeUpdate(); 
          
          trigger_stmt = conn.prepareStatement(
        		  "CREATE OR REPLACE FUNCTION prof_function() RETURNS TRIGGER AS $$ " +
                  "BEGIN " +
        		  "if ((select valid from prof_time) = false)" +
        	      "then raise exception 'There are conflicts of your time'; " + 
        	      "end if;" +
        	      "return new; " + 
        	      "end; $$ language plpgsql;" +
        	      "CREATE OR REPLACE TRIGGER prof_constraint BEFORE INSERT or UPDATE ON weekly_meeting FOR EACH ROW EXECUTE PROCEDURE prof_function();"
          );
          trigger_stmt.executeUpdate();
          
          conn.commit();
          conn.setAutoCommit(true);
 
        // Insertion entries to database
        if (action != null && action.equals("insert")) {
        	
            conn.setAutoCommit(false);  
            
            // Get all data about the course and time
            String course_id = request.getParameter("Course_id");
            String[] id_array = course_id.split(" ");
            
            String course_name =  id_array[0];
            int section_id = Integer.parseInt(id_array[1]);
            int year = Integer.parseInt(id_array[2]);
            String quarter = id_array[3];
            
            String[] start_array = request.getParameter("Start_Time").split(":");
            int start_h = Integer.parseInt(start_array[0]);
            int start_m = Integer.parseInt(start_array[1]);
            
            String[] end_array = request.getParameter("End_Time").split(":");
            int end_h = Integer.parseInt(end_array[0]);
            int end_m = Integer.parseInt(end_array[1]);
            
            // Select all weekly meeting that may conflict with inserted meeting
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
             prof_courses.setString(5, request.getParameter("Day"));
             prof_courses.setInt(6, year);
             prof_courses.setString(7, quarter);
              
             ResultSet prof_rs = prof_courses.executeQuery();
             
             boolean valid = true;
              
              // Loop through every time, if conflicts, set table's valid value to false;
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
              
              // If previous check doesn't find conflict, we go through check for irregular review.
              if (valid == true) {
            	  
            	  // Similarily, select all review that may conflict.
            	  prof_courses = conn.prepareStatement(
                		  "SELECT * from review NATURAL JOIN class " +  
                          "where class.instructor = (select instructor from class where course_name = ? and " + 
                          "section_id = ? and year = ? and quarter = ?) and " +
                          "review.day = ? " + 
                          "and class.year = ? and class.quarter = ?;" 
                		  
                  );
                  prof_courses.setString(1, course_name);
                  prof_courses.setInt(2, section_id);
                  prof_courses.setInt(3, year);
                  prof_courses.setString(4, quarter);
                  prof_courses.setString(5, request.getParameter("Day"));
                  prof_courses.setInt(6, year);
                  prof_courses.setString(7, quarter);
                  
                  prof_rs = prof_courses.executeQuery();
                  
                  // Loop through each time, and check for conflicts. If yes, set valid to false.
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
              }
                
              // Update the value valid in table to indicate whether current insertion is valid.
              PreparedStatement valid_stmt = conn.prepareStatement("update prof_time set valid = ?");
              valid_stmt.setBoolean(1, valid);
              valid_stmt.executeUpdate();
              
            
            // If pass the trigger, we insert the data.
            PreparedStatement stmt_review = conn.prepareStatement(
                "INSERT INTO weekly_meeting VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            
            stmt_review.setString(1, course_name);
            stmt_review.setInt(2, section_id);
            stmt_review.setInt(3, year);
            stmt_review.setString(4, quarter);
            
            stmt_review.setString(5, request.getParameter("Day"));
            stmt_review.setString(6, request.getParameter("Type"));
            stmt_review.setBoolean(7, Boolean.parseBoolean(request.getParameter("Mandatory")));
            stmt_review.setString(8, request.getParameter("Start_Time"));
            stmt_review.setString(9, request.getParameter("End_Time"));
            stmt_review.setString(10, request.getParameter("Building"));
            stmt_review.setString(11, request.getParameter("Room"));
            stmt_review.setInt(12, start_h);
            stmt_review.setInt(13, start_m);
            stmt_review.setInt(14, end_h);
            stmt_review.setInt(15, end_m);
            
            int rowCount = stmt_review.executeUpdate();

            conn.commit();
            conn.setAutoCommit(true);
        }
        
        // Update entries to databbase
        if (action != null && action.equals("update")) {
        	
            conn.setAutoCommit(false);
            
            // Get all information of course and time.
            String course_id = request.getParameter("Course_id");
            String[] id_array = course_id.split(" ");
            
            String course_name =  id_array[0];
            int section_id = Integer.parseInt(id_array[1]);
            int year = Integer.parseInt(id_array[2]);
            String quarter = id_array[3];
            
            String[] start_array = request.getParameter("Start_Time").split(":");
            int start_h = Integer.parseInt(start_array[0]);
            int start_m = Integer.parseInt(start_array[1]);
            
            String[] end_array = request.getParameter("End_Time").split(":");
            int end_h = Integer.parseInt(end_array[0]);
            int end_m = Integer.parseInt(end_array[1]);
            
            // Extract all possible conflict weekly meeting time.
            PreparedStatement prof_courses = conn.prepareStatement(
          		  "SELECT * from weekly_meeting NATURAL JOIN class " +  
                    "where class.instructor = (select instructor from class where course_name = ? and " + 
                    "section_id = ? and year = ? and quarter = ?) and " +
                    "day = ? " + 
                    "and class.year = ? and class.quarter = ?;" 
          		  
            );
            prof_courses.setString(1, course_name);
            prof_courses.setInt(2, section_id);
            prof_courses.setInt(3, year);
            prof_courses.setString(4, quarter);
            prof_courses.setString(5, request.getParameter("Day"));
            prof_courses.setInt(6, year);
            prof_courses.setString(7, quarter);
            
            ResultSet prof_rs = prof_courses.executeQuery();
            
            boolean valid = true;
            
            // Loop through all meeting time, and pass the insertion itself.
            while (prof_rs.next()) {
            	
              if (prof_rs.getString("course_name").equals(course_name) 
                	 && prof_rs.getInt("section_id") == section_id 
                	 && prof_rs.getString("type").equals(request.getParameter("Type"))) {
                		continue;  
              }
  
              int start_h1 = prof_rs.getInt("start_h");
        	  int start_m1 = prof_rs.getInt("start_m");
        	  int end_h1 = prof_rs.getInt("end_h");
        	  int end_m1 = prof_rs.getInt("end_m");
        	  
        	  // If conflict, set valid to false, and break;
        	  if (((( (start_h == end_h1) && (start_m <= end_m1)) || (start_h < end_h1)) &&  
               	 (( (end_h == start_h1) && (end_m >= start_m1)) || (end_h > start_h1)))) {
          		  
          		   valid = false;
                   break;
          	  } 
            }
            
            // Then, we check for review (irregular meeting).
            if (valid == true) {
          	  prof_courses = conn.prepareStatement(
              		  "SELECT * from review NATURAL JOIN class " +  
                        "where class.instructor = (select instructor from class where course_name = ? and " + 
                        "section_id = ? and year = ? and quarter = ?) and " +
                        "review.day = ? " + 
                        "and class.year = ? and class.quarter = ?;" 
              		  
                );
                prof_courses.setString(1, course_name);
                prof_courses.setInt(2, section_id);
                prof_courses.setInt(3, year);
                prof_courses.setString(4, quarter);
                prof_courses.setString(5, request.getParameter("Day"));
                prof_courses.setInt(6, year);
                prof_courses.setString(7, quarter);
                
                prof_rs = prof_courses.executeQuery();
                
                // Loop through every review, and check whether there is conflicts.
                while (prof_rs.next()) {
      
              	  int start_h1 = prof_rs.getInt("start_h");
              	  int start_m1 = prof_rs.getInt("start_m");
              	  int end_h1 = prof_rs.getInt("end_h");
              	  int end_m1 = prof_rs.getInt("end_m");
              	  
              	  // Set valie to false if face conflict.
              	  if (((( (start_h == end_h1) && (start_m <= end_m1)) || (start_h < end_h1)) &&  
                     	 (( (end_h == start_h1) && (end_m >= start_m1)) || (end_h > start_h1)))) {
              		
              		  valid = false;
                      break;
              	  } 
                }
            }
                
            // Update whether the current update is valid.
            PreparedStatement valid_stmt = conn.prepareStatement("update prof_time set valid = ?");
            valid_stmt.setBoolean(1, valid);
            valid_stmt.executeUpdate();
            
            // If pass the trigger, execute the update statement.
            PreparedStatement stmt_review = conn.prepareStatement(
                "UPDATE weekly_meeting SET Mandatory = ?, Start_Time = ?, End_Time = ?, Building = ?, " + 
                "Room = ?, start_h = ?, start_m = ?, end_h = ?, end_m = ? WHERE Course_Name = ? " +
                "AND Section_id = ? AND Year = ? AND Quarter = ? AND Day = ? AND Type = ?");
                      
            stmt_review.setBoolean(1, Boolean.parseBoolean(request.getParameter("Mandatory")));
            stmt_review.setString(2, request.getParameter("Start_Time"));
            stmt_review.setString(3, request.getParameter("End_Time"));
            stmt_review.setString(4, request.getParameter("Building"));
            stmt_review.setString(5, request.getParameter("Room"));
            stmt_review.setInt(6, start_h);
            stmt_review.setInt(7, start_m);
            stmt_review.setInt(8, end_h);
            stmt_review.setInt(9, end_m);
            
            stmt_review.setString(10, course_name);
            stmt_review.setInt(11, section_id);
            stmt_review.setInt(12, year);
            stmt_review.setString(13, quarter);
            
            stmt_review.setString(14, request.getParameter("Day"));
            stmt_review.setString(15, request.getParameter("Type"));
         
            
            int rowCount = stmt_review.executeUpdate();
     
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        
        // Delete entries from databse
        if (action != null && action.equals("delete")) {
         
            conn.setAutoCommit(false);
            
            PreparedStatement stmt_review = conn.prepareStatement(
            	"DELETE FROM weekly_meeting WHERE Course_Name = ? AND Section_id = ? AND Year = ? " +
                "AND Quarter = ? AND Day = ? AND Type = ?");
            
            String course_id = request.getParameter("Course_id");
            String[] id_array = course_id.split(" ");
            
            stmt_review.setString(1, id_array[0]);
            stmt_review.setInt(2, Integer.parseInt(id_array[1]));
            stmt_review.setInt(3, Integer.parseInt(id_array[2]));
            stmt_review.setString(4, id_array[3]);
            
            stmt_review.setString(5, request.getParameter("Day"));
            stmt_review.setString(6, request.getParameter("Type"));
            
            int rowCount = stmt_review.executeUpdate();
            
            conn.commit();
            conn.setAutoCommit(true);
        }
    %>
    
     
     <%      
           Statement statement = conn.createStatement();        
           ResultSet rs = statement.executeQuery ("SELECT * FROM weekly_meeting");
           
     %>     
     
     <table>
         <tr>
               <th>Class_info</th>
               <th>Day</th>
               <th>Type</th>
               <th>Mandatory</th>
               <th>Start_Time</th>
               <th>End_Time</th>
               <th>Building</th>
               <th>Room</th>
         </tr>
         
         <tr>
               <form action="weekly_meeting.jsp" method="get">
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
                   
                   <th><div>
                       <input type="radio" name="Day" value="Mon">Mon
				       <br>
					   <input type="radio" name="Day" value="Tue">Tue
					   <br>
					   <input type="radio" name="Day" value="Wed">Wed
					   <br>
					   <input type="radio" name="Day" value="Thu">Thu
					   <br>
					   <input type="radio" name="Day" value="Fri">Fri
					   <br>
					   <input type="radio" name="Day" value="Sat">Sat
					   <br>
					   <input type="radio" name="Day" value="Sun">Sun
					</div></th>
					
					<th><div>
                       <input type="radio" name="Type" value="Lecture">Lecture
				       <br>
					   <input type="radio" name="Type" value="Discussion">Discussion
					   <br>
					   <input type="radio" name="Type" value="Lab">Lab
					</div></th>
					
					<th><div>
				       	  	 <br>
					  		 <input type="radio" name="Mandatory" value="True">Yes
					   		 <br>
					   		 <input type="radio" name="Mandatory" value="False" checked>No
					</div></th>
					
                   <th><input value="" name="Start_Time" size="10"></th>
                   <th><input value="" name="End_Time" size="10"></th>
                   <th><input value="" name="Building" size="10"></th>
                   <th><input value="" name="Room" size="10"></th>
                   <th><input type="submit" value="Insert"></th>
               </form>
         </tr>
           
     <%   
           // Looping every entries in weekly database, and update the information to table.
           while (rs.next()) {
     %>
    	  <tr>
             <form action="weekly_meeting.jsp" method="get">
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
                   			<option value="<%= course_id2 %>"> 
                   		         <%= course_id2 %></option>
        
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
					<br>
						<input type="radio" name="Day" value="Mon" <%=rs.getString("Day").equals("Mon") ? "checked" : ""  %>  >Mon
						<br>
						<input type="radio" name="Day" value="Tue" <%=rs.getString("Day").equals("Tue") ? "checked" : ""  %>  >Tue
						<br>
						<input type="radio" name="Day" value="Wed" <%=rs.getString("Day").equals("Wed") ? "checked" : ""  %>  >Wed
						<br>
						<input type="radio" name="Day" value="Thu" <%=rs.getString("Day").equals("Thu") ? "checked" : ""  %>  >Thu
						<br>
						<input type="radio" name="Day" value="Fri" <%=rs.getString("Day").equals("Fri") ? "checked" : ""  %>  >Fri
						<br>
						<input type="radio" name="Day" value="Sat" <%=rs.getString("Day").equals("Sat") ? "checked" : ""  %>  >Sat
						<br>
						<input type="radio" name="Day" value="Sun" <%=rs.getString("Day").equals("Sun") ? "checked" : ""  %>  >Sun
			     </td>
			     
			     <td>
					<br>
						<input type="radio" name="Type" value="Lecture" <%=rs.getString("Type").equals("Lecture") ? "checked" : ""  %>  >Lecture
						<br>
						<input type="radio" name="Type" value="Discussion" <%=rs.getString("Type").equals("Discussion") ? "checked" : ""  %>  >Discussion
						<br>
						<input type="radio" name="Type" value="Lab" <%=rs.getString("Type").equals("Lab") ? "checked" : ""  %>  >Lab
						<br>
			     </td>
			     
			     <td>
						<br>
						<input type="radio" name="Mandatory" value="True"  <%=rs.getBoolean("Mandatory") == true ? "checked" : ""  %>  >Yes
						<br>
						<input type="radio" name="Mandatory" value="False" <%=rs.getBoolean("Mandatory") == false ? "checked" : ""  %>  >No
						<br>
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
             
             
             <form action="weekly_meeting.jsp" method="get">
                 <input type="hidden" value="delete" name="action">
                 
                 <input type="hidden" value="<%= course_id2 %>" 
                 name="Course_id">
                 
                 <input type="hidden" value="<%= rs.getString("Day") %>" 
                 name="Day">
                 <input type="hidden" value="<%= rs.getString("Type") %>" 
                 name="Type">
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
    	  out.println(e1.getMessage());
    	  
      } catch (Exception e2) {
    	  out.println(e2.getMessage());
      }
      %>
      
     </td>
     </tr>
     </table>

</body>
</html>