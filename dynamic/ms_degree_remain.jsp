<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>MS degree remaining</title>
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
        
        ResultSet student_info = null;
        ResultSet class_info = null;
        ResultSet degree_info = null;
        
        // We set the HashMap to record the information of students' degree and courses;
        HashMap <String, String[]> concentration_course = new HashMap<>();
        HashMap <String, Integer> concentration_unit = new HashMap<>();
        HashSet <String> student_course = new HashSet<>();
        HashMap <String, Integer> course_unit = new HashMap<>();
        
        
        // Select all undergraduate student information
        conn.setAutoCommit(false);
    	PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM student where id in (select id from ms)");
    	
    	student_info = pstmt2.executeQuery();
    	conn.commit();
    	conn.setAutoCommit(true);
    	
    	
        // Select class info from student, and degree info from student's major
        if (action != null && action.equals("submit")) {
        	
            conn.setAutoCommit(false);
            
            String major = null;
            
            PreparedStatement pstmt4 = conn.prepareStatement(
    				"SELECT * FROM ms where id = ?"
    		);
            
            pstmt4.setString(1, request.getParameter("student_id"));
            ResultSet major_info = pstmt4.executeQuery();
            
            while (major_info.next()) {
            	major = major_info.getString("major");
            }
     
            // Select the degree info from student's major
            PreparedStatement pstmt = conn.prepareStatement(
				"SELECT * FROM degree where degree_name = ? AND type = ?"
			);
			
            pstmt.setString(1, major);
            pstmt.setString(2, "MS");

            degree_info = pstmt.executeQuery();
            
            // Select the class info from that student's classes taken in the past.
            PreparedStatement pstmt3 = conn.prepareStatement(
    				"SELECT * FROM class_taken_in_the_past where id = ?"
    		);
    			
            pstmt3.setString(1, request.getParameter("student_id"));

            class_info = pstmt3.executeQuery();
            
            conn.commit();
            conn.setAutoCommit(true);
            
        }

    %> 
            <%-- presentation --%>
            
            <h2>Choose Student</h2>
			<form action="ms_degree_remain.jsp" method="POST">
		
			<div>
				Student:
				<select name="student_id">
					<%
					if (student_info.isBeforeFirst())
					{
						while(student_info.next()){
	                       
							%>
							<option value="<%=student_info.getString("id")%>"> 
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
		 
		  
		  <h2>Student's degree info</h2>
		
		  <h3> </h3>
		 <table>
	 	 <tr>
	 	     <th>Student id</th>
	   		 <th>Units Remaining</th>
	   		 <th>Concentration details</th>

	    </tr>
	 	 
	 	<% 	
	 	    // We record degree information into two hashMap (category to courses, and concentration to required units).
	 		if (degree_info != null) {
  				if (degree_info.isBeforeFirst()) {
					while(degree_info.next()) { 
						String[] concentration_list = degree_info.getString("concentration").split(",");
						
						ResultSet concentration_info = null;
						
						// Select all concentration name from the concentration list getted from degree info
						for (String concentration_name : concentration_list) {
							
							// For each concentration name, we select all required courses and required units.
			            	PreparedStatement pstmt = conn.prepareStatement(
			            			"SELECT * FROM concentration where concentration_name = ?"
			    			);
			    			
							// Execute to get the courses an units information
			           		pstmt.setString(1, concentration_name);
			           		concentration_info = pstmt.executeQuery();
			           		
			           		// We translate that course_info String to list, and store these into map
			           		while(concentration_info.next()) { 
			           			String[] course_info = concentration_info.getString("course_info").split(",");
			           			concentration_course.put(concentration_name, course_info);
			           			concentration_unit.put(concentration_name, concentration_info.getInt("req_units"));
			           		}
			           		concentration_info.close();
						}				
					}
				}	
  			}
	 		
	 		// We store the student's course information in hashSet, and mapping course to units.
	 		if (class_info != null) {
  				if (class_info.isBeforeFirst()) {
					while(class_info.next()) { 
						String course_name = class_info.getString("course_title");
						int units = class_info.getInt("units");
						student_course.add(course_name);
						course_unit.put(course_name, units);
					}
				}	
  			}
	 		
	 		int total_units = 0;
	 		String concentration_details = "";
	 		
	 		// Loop through every concentration name in the required degree.
	 		for (String concentration_name : concentration_course.keySet()) {
	 			
	 			// We set the total units needed to be finish for this concentration.
	 			int units = concentration_unit.get(concentration_name);
	 					
	 		    // We then loop through every course in the concentration requirement.
	 			for (String course : concentration_course.get(concentration_name)) {
	 				
	 				// If student have that course, we substrat that from total units, until smaller than 0.
	 				if (student_course.contains(course)) {
	 					int current_unit = course_unit.get(course);
	 					if (units < current_unit) {
	 						break;
	 					}
	 				    units -= current_unit;
	 				}
	 			}
	 		    
	 		    // We add the remianing units together to calculate the total units remaining.
	 		    total_units += units;
	 		    // We also record the category details as string. 
	 		    concentration_details += concentration_name + " needs : " + units + "; ";
	 		}
	 		
	 		if (class_info != null) {
	 		%>
	 			<tr>
	   				<td><%= request.getParameter("student_id") %></td>
	   				<td><%= total_units %></td>
	    			<td><%= concentration_details %></td>
				</tr>
			
	 		<% 
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