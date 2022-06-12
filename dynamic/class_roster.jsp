<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>class roster</title>
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
        
        // Select all class's information
        conn.setAutoCommit(false);
    	PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM class");
    	
    	class_info = pstmt2.executeQuery();
    	conn.commit();
    	conn.setAutoCommit(true);
    	
    	
        // Select all student in class
        if (action != null && action.equals("submit")) {
        	
            conn.setAutoCommit(false);
            
            PreparedStatement pstmt = null;
            
            String[] info = request.getParameter("class_information").split(" "); 
            int year = Integer.parseInt(info[1]);
            String quarter = info[2];
            
            if (year == 2022 && quarter.equals("SP")) {
            	
            	pstmt = conn.prepareStatement(
        				"SELECT * FROM student NATURAL JOIN course_enrollment c where c.section_id = ? AND c.course_name = ?"
        		);
            	
                pstmt.setInt(1, Integer.parseInt(info[3]));
                pstmt.setString(2, info[0]);
            	
            } else {
            	
            	pstmt = conn.prepareStatement(
        				"SELECT * FROM student NATURAL JOIN class_taken_in_the_past c where c.year = ? AND c.quarter = ? AND c.section_id = ? AND c.course_title = ?"
        		);
            	
            	pstmt.setInt(1, year);
                pstmt.setString(2, quarter);
                pstmt.setInt(3, Integer.parseInt(info[3]));
                pstmt.setString(4, info[0]);	
            }
                 
            student_info = pstmt.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);
        }

    %> 

            <%-- presentation --%>
            
            <h2>Choose Class</h2>
			<form action="class_roster.jsp" method="POST">
		
			<div>
				Class:
				<select name="class_information">
					<%
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
					%>
				</select>
			</div>
		
			<button type="submit" name="action" value="submit">Submit</button>
		
		  </form>
		 
		  
		  <h3>Enrolled Students in </h3>
		  <p><%= request.getParameter("class_information") %></p>
		 
	
		 <table>
	 	 <tr>
	 	     <th>ID</th>
	   		 <th>First_Name</th>
	   		 <th>Middle_Name</th>
	   		 <th>Last_Name</th>
	   		 <th>SSN</th>
	   		 <th>Residency</th>
	    	 <th>Units</th>
	    	 <th>Grade Option</th>
	    </tr>
	 	 
	 	<%
	  		if (student_info != null) {
	  			if (student_info.isBeforeFirst()) {
					while(student_info.next()) { 
						%>
				
		  				<tr>
					   		<td><%=student_info.getString("id") %></td>
					   		<td><%=student_info.getString("first_name") %></td>
					    	<td><%=student_info.getString("middle_name") %></td>
					    	<td><%=student_info.getString("last_name") %></td>
					    	<td><%=student_info.getString("ssn") %></td>
					    	<td><%=student_info.getString("residency") %></td>
					    	<td><%=student_info.getString("units") %></td>
					    	<%
					    		String grade_option = student_info.getString("grade");
					    	
					    		if (grade_option.equals("S/U") || grade_option.equals("S") || grade_option.equals("U") || grade_option.equals("IN")) {
					    			grade_option = "S/U";
					    		} else {
					    			grade_option = "Letter";
					    		}
					    	
					    	%>
					    	<td><%=grade_option %></td>
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