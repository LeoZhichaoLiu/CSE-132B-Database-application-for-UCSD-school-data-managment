<%@ page import="java.sql.*" %>
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
        
        String action = request.getParameter("action");
        
        // Insertion entries to database
        if (action != null && action.equals("insert")) {
        	
            conn.setAutoCommit(false);
            
            String course_name = request.getParameter("Course_Name");
            int section_id = Integer.parseInt(request.getParameter("Section_id"));
            int enrollment_limit = Integer.parseInt(request.getParameter("Enrollment_Limit"));
            
            PreparedStatement stmt_class = conn.prepareStatement(
                "INSERT INTO Class VALUES (?, ?, ?, ?, ?, ?, ?)");
            
            stmt_class.setString(1, course_name);
            stmt_class.setInt(2, section_id);
            stmt_class.setInt(3, Integer.parseInt(request.getParameter("Year")));
            stmt_class.setString(4, request.getParameter("Quarter"));
            stmt_class.setString(5, request.getParameter("Class_Title"));
            stmt_class.setInt(6, enrollment_limit);
            stmt_class.setString(7, request.getParameter("Instructor"));
            
            stmt_class.executeUpdate();
            
            
            // Create table to record the currented enrolled limits of that class.
            PreparedStatement stmt_enrolled = conn.prepareStatement(
                    "INSERT INTO current_enrolled VALUES (?, ?, ?, ?)"
            );
            
            stmt_enrolled.setString(1, course_name);
            stmt_enrolled.setInt(2, section_id);
            stmt_enrolled.setInt(3, enrollment_limit);
            stmt_enrolled.setInt(4, 0);
            
            stmt_enrolled.executeUpdate();
            
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        // Update entries to databbase
        if (action != null && action.equals("update")) {
        	
            conn.setAutoCommit(false);
            
            // Updating class information by changing limits, instructors, and title.
            PreparedStatement stmt_class = conn.prepareStatement(
                "UPDATE Class SET Class_Title = ?, Enrollment_Limit = ?, Instructor = ?" + 
                "WHERE Course_Name = ? AND Section_id = ? AND Year = ? AND Quarter = ?");
            
            stmt_class.setString(1, request.getParameter("Class_Title"));
            stmt_class.setInt(2, Integer.parseInt(request.getParameter("Enrollment_Limit")));
            stmt_class.setString(3, request.getParameter("Instructor"));
            stmt_class.setString(4, request.getParameter("Course_Name"));
            stmt_class.setInt(5, Integer.parseInt(request.getParameter("Section_id")));
            stmt_class.setInt(6, Integer.parseInt(request.getParameter("Year")));
            stmt_class.setString(7, request.getParameter("Quarter"));
            
            
            int rowCount = stmt_class.executeUpdate();
            
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        
        // Delete entries from databse
        if (action != null && action.equals("delete")) {
           
            conn.setAutoCommit(false);
            
            // Delete the class defined by its course name, year/quarter, and section id.
            PreparedStatement stmt_class = conn.prepareStatement(
            	"DELETE FROM Class WHERE Course_Name = ? AND Section_id = ? AND Year = ? AND Quarter = ?");
            
            String course_name = request.getParameter("Course_Name");
            int section_id = Integer.parseInt(request.getParameter("Section_id"));
            int year = Integer.parseInt(request.getParameter("Year"));
            String quarter = request.getParameter("Quarter");
            
            stmt_class.setString(1, course_name);
            stmt_class.setInt(2, section_id);
            stmt_class.setInt(3, year);
            stmt_class.setString(4, quarter);
            
            stmt_class.executeUpdate();
            
            // Delete current_enrolled table
            PreparedStatement delete_enroll = conn.prepareStatement(
                	"DELETE FROM current_enrolled WHERE Course_Name = ? AND Section_id = ?"
            );
            
            delete_enroll.setString(1, course_name);
            delete_enroll.setInt(2, section_id);
            
            delete_enroll.executeUpdate();
            
            
            // Delete review and weekly meeting that using class_id as primary key.
            PreparedStatement delete_review = conn.prepareStatement(
                	"DELETE FROM Review WHERE Course_Name = ? AND Section_id = ? AND Year = ? AND Quarter = ?");
            PreparedStatement delete_week = conn.prepareStatement(
                	"DELETE FROM weekly_meeting WHERE Course_Name = ? AND Section_id = ? AND Year = ? AND Quarter = ?");           

            delete_review.setString(1, course_name);
            delete_review.setInt(2, section_id);
            delete_review.setInt(3, year);
            delete_review.setString(4, quarter);
                       
            delete_week.setString(1, course_name);
            delete_week.setInt(2, section_id);
            delete_week.setInt(3, year);
            delete_week.setString(4, quarter);
            
            delete_review.executeUpdate();
            delete_week.executeUpdate();
            
            
            conn.commit();
            conn.setAutoCommit(true);
        }
    %>
     
     <%      
           Statement statement = conn.createStatement();        
           ResultSet rs = statement.executeQuery ("SELECT * FROM Class");
           
     %>     
     
     <table>
         <tr>
               <th>Course_Name</th>
               <th>Section_id</th>
               <th>Year</th>
               <th>Quarter</th>
               <th>Class_Title</th>
               <th>Enrollment_Limit</th>
               <th>Instructor</th>
         </tr>
         
         <tr>
               <form action="Class.jsp" method="get">
                   <input type="hidden" value="insert" name="action">
                   <%
                   		Statement statement2 = conn.createStatement();        
                   		ResultSet rs2 = statement2.executeQuery ("select * from course");
                   %>
                   <th>
                   		<select name="Course_Name">
                   			<%   while (rs2.next()) {   
                   				 String course_id = rs2.getString("Course_Name");
                   			%>
  								<option value="<%= course_id%>"><%= course_id%></option>
  							<%  }  %>
						</select>
                   </th>
                   <th><input value="" type="number" name="Section_id" min="1" max="10"></th>
                   <th><input value="" type="number" name="Year" min="1960" max="2022"></th>
                   <th><div>
                       <input type="radio" name="Quarter" value="FA">FALL
				       <br>
					   <input type="radio" name="Quarter" value="WI">Winter
					   <br>
					   <input type="radio" name="Quarter" value="SP">Spring
					</div></th>
                   <th><input value="" name="Class_Title" size="15"></th>
                   <th><input value="" type="number" name="Enrollment_Limit" min="0" max="500"></th>
                   <%
                   		Statement statement4 = conn.createStatement();        
                   		ResultSet rs4 = statement4.executeQuery ("select * from faculty");
                   %>
                   <th>
                   		<select name="Instructor">
                   			<%   while (rs4.next()) {   
                   				 String instructor_name = rs4.getString("name");
                   			%>
  								<option value="<%= instructor_name%>"><%= instructor_name%></option>
  							<%  }  %>
						</select>
                   </th>
                   <th><input type="submit" value="Insert"></th>
               </form>
         </tr>
           
     <%   
           // Looping every entries in class database, and update the information to table.
           while (rs.next()) {
     %>
    	  <tr>
             <form action="Class.jsp" method="get">
                <input type="hidden" value="update" name="action">
				
				<%
                   	Statement statement3 = conn.createStatement();        
                   	ResultSet rs3 = statement3.executeQuery ("select * from course");
                 %>
                   <th>
                   		<select name="Course_Name">
                   		    <option value="<%= rs.getString("Course_Name") %>"> 
                   		         <%= rs.getString("Course_Name") %></option>
                   			<%   while (rs3.next()) {   
                   				 String course_id = rs3.getString("Course_Name");
                   			%>
  								<option value="<%= course_id%>"><%= course_id%></option>
  							<%  }  %>
						</select>
                   </th>
                <td>
                	<th><input type="number" name="Section_id" value="<%= rs.getInt("Section_id") %>"></th>
                </td> 
                <td>
                   <th><input type="number" name="Year" value="<%= rs.getInt("Year") %>" ></th>
                </td>
                
                <td>
					<br>
						<input type="radio" name="Quarter" value="FA" <%=rs.getString("Quarter").equals("FA") ? "checked" : ""  %>  >FA
						<br>
						<input type="radio" name="Quarter" value="WI" <%=rs.getString("Quarter").equals("WI") ? "checked" : ""  %>  >WI
						<br>
						<input type="radio" name="Quarter" value="SP" <%=rs.getString("Quarter").equals("SP") ? "checked" : ""  %>  >SP
						<br>
			     </td>
                <td>
                    <input value="<%= rs.getString("Class_Title") %>" 
                    name="Class_Title" size="15">
                 </td>
                 <td>
                    <input type = "number" name="Enrollment_Limit" value="<%= rs.getInt("Enrollment_Limit") %>" >
                 </td> 
                 <%
                   	Statement statement5 = conn.createStatement();        
                   	ResultSet rs5 = statement5.executeQuery ("select * from faculty");
                 %>
                   <th>
                   		<select name="Instructor">
                   		    <option value="<%= rs.getString("Instructor") %>"> 
                   		         <%= rs.getString("Instructor") %></option>
                   			<%   while (rs5.next()) {   
                   				 String instructor_name = rs5.getString("name");
                   			%>
  								<option value="<%= instructor_name%>"><%= instructor_name%></option>
  							<%  }  %>
						</select>
                   </th>
                       
                 <td>
                    <input type="submit" value="Update">
                 </td>
             </form>
             
             
             <form action="Class.jsp" method="get">
                 <input type="hidden" value="delete" name="action">
                 <input type="hidden" value="<%= rs.getString("Course_Name") %>" 
                 name="Course_Name">
                 <input type="hidden" value="<%= rs.getInt("Section_id") %>" 
                 name="Section_id">
                 <input type="hidden" value="<%= rs.getInt("Year") %>" 
                 name="Year">
                 <input type="hidden" value="<%= rs.getString("Quarter") %>" 
                 name="Quarter">
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