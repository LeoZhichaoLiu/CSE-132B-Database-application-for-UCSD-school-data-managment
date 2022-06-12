<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Course Entry</title>
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
            
            PreparedStatement stmt_course = conn.prepareStatement(
                "INSERT INTO Course VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            
            
            boolean valid_input = true;
             
             if (!request.getParameter("Prerequisite").equals("")) {
             	String[] pre_list = request.getParameter("Prerequisite").split(",");
	    	 	for (String item : pre_list) {
	    			PreparedStatement p5 = conn.prepareStatement("select * from Course WHERE " +
                 	       "Course_Name = ? ");
             		p5.setString(1, item);
             		ResultSet r = p5.executeQuery();
             		if (!r.next()) {
             		
           		%>
             		<b style="font-size:25px"> Course <%= item %> is not registered! Please register first!"</b>
            	<%  
                	valid_input = false;
                	break;
             	    }
	    	     }
            }

	    	if (valid_input) {
            stmt_course.setString(1, request.getParameter("Course_Name"));
            stmt_course.setString(2, request.getParameter("Department"));
            stmt_course.setInt(3, Integer.parseInt(request.getParameter("Min_Units")));
            stmt_course.setInt(4,  Integer.parseInt(request.getParameter("Max_Units")));
            stmt_course.setBoolean(5, Boolean.parseBoolean(request.getParameter("Lab")));
            stmt_course.setString(6, request.getParameter("Grading_Option"));
            stmt_course.setBoolean(7, Boolean.parseBoolean(request.getParameter("Consent")));
            stmt_course.setString(8, request.getParameter("Prerequisite"));
            stmt_course.setString(9, request.getParameter("Level"));
            
            int rowCount = stmt_course.executeUpdate();
	    	}
            
            
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        // Update entries to databbase
        if (action != null && action.equals("update")) {
        	
           
            conn.setAutoCommit(false);
            
            PreparedStatement stmt_course = conn.prepareStatement(
                "UPDATE Course SET Department = ?, Min_Units = ?, Max_Units = ?, " + 
                "Lab = ?, Grading_Option = ?, Consent = ?, Prerequisite = ?, Level = ? " +
                "WHERE Course_Name = ?");
           
            
            stmt_course.setString(1, request.getParameter("Department"));
            stmt_course.setInt(2, Integer.parseInt(request.getParameter("Min_Units")));
            stmt_course.setInt(3, Integer.parseInt(request.getParameter("Max_Units")));
            stmt_course.setBoolean(4, Boolean.parseBoolean(request.getParameter("Lab")));
            stmt_course.setString(5, request.getParameter("Grading_Option"));
            stmt_course.setBoolean(6, Boolean.parseBoolean(request.getParameter("Consent")));   
            stmt_course.setString(7, request.getParameter("Prerequisite"));
            stmt_course.setString(8, request.getParameter("Level"));
            stmt_course.setString(9, request.getParameter("Course_Name"));
            
            
            int rowCount = stmt_course.executeUpdate();
            
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        // Delete entries from databse
        if (action != null && action.equals("delete")) {
        	
            conn.setAutoCommit(false);
            
            // Delete all entries of that course from course and course_pre db.
            PreparedStatement stmt_course = conn.prepareStatement(
            	"DELETE FROM Course WHERE Course_Name = ?");
            
            String course_name = request.getParameter("Course_Name");
            stmt_course.setString(1, course_name);
          
            
            int rowCount = stmt_course.executeUpdate();
            
            // Delete all related entries in other table using course as primary key
            PreparedStatement delete_class = conn.prepareStatement(
                	"DELETE FROM Class WHERE Course_Name = ?");
            PreparedStatement delete_review = conn.prepareStatement(
                	"DELETE FROM Review WHERE Course_Name = ?");
            PreparedStatement delete_week = conn.prepareStatement(
                	"DELETE FROM weekly_meeting WHERE Course_Name = ?");
            
            delete_class.setString(1, course_name);
            delete_review.setString(1, course_name);
            delete_week.setString(1, course_name);
            
            delete_class.executeUpdate();
            delete_review.executeUpdate();
            delete_week.executeUpdate();
            
            conn.commit();
            conn.setAutoCommit(true);
        }
    %>
    
     
     <%      
           Statement statement = conn.createStatement();        
           ResultSet rs = statement.executeQuery ("SELECT * FROM Course");
           
     %>     
     
     <table>
         <tr>
               <th>Course_Name</th>
               <th>Department</th>
               <th>Min_Units</th>
               <th>Max_Units</th>
               <th>Lab</th>
               <th>grading Option</th>
               <th>Consent</th>
               <th>Prerequisite(',' separate))</th>
               <th>Level</th>
         </tr>
         
         <tr>
               <form action="Course.jsp" method="get">
                   <input type="hidden" value="insert" name="action">
                   <th><input value="" name="Course_Name" size="10"></th>
                   <%
                   		Statement statement2 = conn.createStatement();        
                   		ResultSet rs2 = statement2.executeQuery ("select * from department");
                   %>
                   	<th>
                   		<select name="Department">
                   			<%   while (rs2.next()) {   
                   				 	String department_name = rs2.getString("name");
                   			%>
  									<option value="<%= department_name%>"><%= department_name%></option>
  							<%  }  %>
						</select>
                   </th>
                   <th><input value="0" type="number" name="Min_Units" min="0"></th>
                   <th><input value="0" type="number" name="Max_Units" min="0"></th>
                   <th><div>
				       <br>
					   <input type="radio" name="Lab" value="True">Yes
					   <br>
					   <input type="radio" name="Lab" value="False" checked>No
					</div></th>
                  	<th><div>
						<br>
					<input type="radio" name="Grading_Option" value="Letter" checked>Letter
						<br>
					<input type="radio" name="Grading_Option" value="S/U">S/U
						<br>
					<input type="radio" name="Grading_Option" value="Both">Both
						<br>
					</div></th>
					<th><div>
				       <br>
					   <input type="radio" name="Consent" value="True">Yes
					   <br>
					   <input type="radio" name="Consent" value="False" checked>No
					</div></th>
                   <th><input value="" name="Prerequisite" size="30"></th>
                   <th><div>
						<br>
					<input type="radio" name="Level" value="Lower" checked>Lower
						<br>
					<input type="radio" name="Level" value="Upper">Upper
					</div></th>
                   <th><input type="submit" value="Insert"></th>
               </form>
         </tr>
           
     <%   
           // Looping every entries in course database, and update the information to table.
           while (rs.next()) {
     %>
    	  <tr>
             <form action="Course.jsp" method="get">
                <input type="hidden" value="update" name="action">

                <td>
                   <input value="<%= rs.getString("Course_Name") %>" 
                   name="Course_Name" size="10">
                </td>
                <%
                   	Statement statement3 = conn.createStatement();        
                   	ResultSet rs3 = statement3.executeQuery ("select * from department");
                 	%>
                   <th>
                   		<select name="Department">
                   		    <option value="<%= rs.getString("department") %>"> 
                   		         <%= rs.getString("department") %></option>
                   			<%   while (rs3.next()) {   
                   				 String department_name = rs3.getString("name");
                   			%>
  								<option value="<%= department_name%>"><%= department_name%></option>
  							<%  }  %>
						</select>
                   </th>
                <td>
                	<input type="number" name="Min_Units" value="<%=rs.getInt("Min_Units") %>">
                </td>
                <td>
                	<input type="number" name="Max_Units" value="<%=rs.getInt("Max_Units") %>">
                </td>
                <td>
					<br>
					<input type="radio" name="Lab" value="True"  <%=rs.getBoolean("Lab") == true ? "checked" : ""  %>  >Yes
					<br>
					<input type="radio" name="Lab" value="False" <%=rs.getBoolean("Lab") == false ? "checked" : ""  %>  >No
					<br>
			    </td>
                 <td>
					<br>
						<input type="radio" name="Grading_Option" value="Letter" <%=rs.getString("Grading_Option").equals("Letter") ? "checked" : ""  %>  >Letter
						<br>
						<input type="radio" name="Grading_Option" value="S/U" <%=rs.getString("Grading_Option").equals("S/U") ? "checked" : ""  %>  >S/U
						<br>
						<input type="radio" name="Grading_Option" value="Both" <%=rs.getString("Grading_Option").equals("Both") ? "checked" : ""  %>  >Both
						<br>
			     </td>
			     <td>
					<br>
					<input type="radio" name="Consent" value="True"  <%=rs.getBoolean("Consent") == true ? "checked" : ""  %>  >Yes
					<br>
					<input type="radio" name="Consent" value="False" <%=rs.getBoolean("Consent") == false ? "checked" : ""  %>  >No
					<br>
			    </td>       
			    <% 
			      
			       if (rs.getString("Prerequisite").equals("")) { %>   
			   		 <td>
                         <input value= "" name="Prerequisite" size="30">
                 	</td>  
			    <%} else { 
			  
			    %>       
                 <td>
                    <input value= <%= rs.getString("Prerequisite") %> name="Prerequisite" size="30">
                 </td>   
                 <%} %>       
                 
                 <td>
					<br>
						<input type="radio" name="Level" value="Lower" <%=rs.getString("Level").equals("Lower") ? "checked" : ""  %>  >Lower
						<br>
						<input type="radio" name="Level" value="Upper" <%=rs.getString("Level").equals("Upper") ? "checked" : ""  %>  >Upper
			     </td>
                 
                 <td>
                    <input type="submit" value="Update">
                 </td>
             </form>
             
             
             <form action="Course.jsp" method="get">
                 <input type="hidden" value="delete" name="action">
                 <input type="hidden" value="<%= rs.getString("Course_Name") %>" 
                   name="Course_Name">
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