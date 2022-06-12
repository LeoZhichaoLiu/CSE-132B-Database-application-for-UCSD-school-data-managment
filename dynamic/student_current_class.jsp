<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Student's current class</title>
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
        
        ResultSet class_info = null;
        ResultSet student_info = null;
        
        // Select all students' information
        conn.setAutoCommit(false);
    	PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM student");
    	
    	student_info = pstmt2.executeQuery();
    	conn.commit();
    	conn.setAutoCommit(true);
    	
    	
        // Select all class that students enrolled.
        if (action != null && action.equals("submit")) {
        	
            conn.setAutoCommit(false);
            
            PreparedStatement pstmt = conn.prepareStatement(
				"SELECT * FROM course_enrollment where id = (select id from student where ssn = ?)");
		
            pstmt.setString(1, request.getParameter("ssn"));
            
            class_info = pstmt.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);
        }

    %> 

            <%-- presentation --%>
            
            <h2>Choose Student</h2>
			<form action="student_current_class.jsp" method="POST">
		
			<div>
				Student:
				<select name="ssn">
					<%
					if (student_info.isBeforeFirst())
					{
						while(student_info.next()){
							%>
							<option value=<%=student_info.getString("ssn")%>> 
							<%=student_info.getString("first_name")%> 
							<%=student_info.getString("middle_name").equals("NULL")? " " : student_info.getString("middle_name")%> 
							<%=student_info.getString("last_name")%> 
							 (SSN: <%=student_info.getString("ssn")%>)
							</option>
							<%
						}
					}
					%>
				</select>
			</div>
		
			<button type="submit" name="action" value="submit">Submit</button>
		
		  </form>
		  
		  <% 
		  PreparedStatement pstmt = conn.prepareStatement(
					"SELECT * from student where ssn = ?");
			
	      pstmt.setString(1, request.getParameter("ssn"));
	            
	      ResultSet student_res = pstmt.executeQuery();
	      
		  String first = "";
		  String middle = "";
		  String last = "";
		  String ssn = "";
		  if (student_res != null) {
	  			if (student_res.isBeforeFirst()) {
					while(student_res.next()) { 
		  				 first = student_res.getString("first_name");
		  				 middle = student_res.getString("middle_name");
		  				 last = student_res.getString("last_name");
		  				 ssn = student_res.getString("ssn");
					}
	  			}
		  }
		  %>
		  
		  <h2>Classes by </h2>
		  <h3><%= first %> <%= middle %> <%= last %> <%= ssn %> </h3>
	
		 <table>
	 	 <tr>
	   		 <th>Course</th>
	   		 <th>Section</th>
	    	 <th>Units</th>
	    </tr>
	 	 
	 	<%
	  		if (class_info != null) {
	  			if (class_info.isBeforeFirst()) {
					while(class_info.next()) { 
						%>
				
		  				<tr>
					   		<td><%=class_info.getString("course_name") %></td>
					   		<td><%=class_info.getString("section_id") %></td>
					    	<td><%=class_info.getString("units") %></td>
						</tr>
						
					    <%
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