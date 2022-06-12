<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>undergraduate degree remaining</title>
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
        HashMap <String, String[]> category_course = new HashMap<>();
        HashMap <String, Integer> category_unit = new HashMap<>();
        HashSet <String> student_course = new HashSet<>();
        HashMap <String, Integer> course_unit = new HashMap<>();
        
        
        // Select all undergraduate student information
        conn.setAutoCommit(false);
    	PreparedStatement pstmt2 = conn.prepareStatement("SELECT * FROM student where id in (select id from undergraduate)");
    	
    	student_info = pstmt2.executeQuery();
    	conn.commit();
    	conn.setAutoCommit(true);
    	
    	
        // Select class infor from student, and degree info from student's major
        if (action != null && action.equals("submit")) {
        	
            conn.setAutoCommit(false);
            
            String major = null;
            
            PreparedStatement pstmt4 = conn.prepareStatement(
    				"SELECT * FROM undergraduate where id = ?"
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
            pstmt.setString(2, "BS");

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
			<form action="undergrad_degree_remain.jsp" method="POST">
		
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
	   		 <th>Category details</th>

	    </tr>
	 	 
	 	<% 	
	 	    // We record degree information into two hashMap (category to courses, and category to required units).
	 		if (degree_info != null) {
  				if (degree_info.isBeforeFirst()) {
					while(degree_info.next()) { 
						String[] category_list = degree_info.getString("category").split(",");
						
						ResultSet category_info = null;
						
						// Select all category name from the category list getted from degree info
						for (String category_name : category_list) {
							
							// For each category name, we select all required courses and required units.
			            	PreparedStatement pstmt = conn.prepareStatement(
			            			"SELECT * FROM category where category_name = ?"
			    			);
			    			
							// Execute to get the courses an units information
			           		pstmt.setString(1, category_name);
			           		category_info = pstmt.executeQuery();
			           		
			           		// We translate that course_info String to lst, and store these into map
			           		while(category_info.next()) { 
			           			String[] course_info = category_info.getString("course_info").split(",");
			           			category_course.put(category_name, course_info);
			           			category_unit.put(category_name, category_info.getInt("req_units"));
			           		}
			           		category_info.close();
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
	 		String category_details = "";
	 		
	 		// Loop through every category name in the required degree.
	 		for (String category_name : category_course.keySet()) {
	 			
	 			// We set the total units needed to be finish for this category.
	 			int units = category_unit.get(category_name);
	 					
	 		    // We then loop through every course in the category requirement.
	 			for (String course : category_course.get(category_name)) {
	 				
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
	 		    category_details += category_name + " needs : " + units + "; ";
	 		}
	 		
	 		if (class_info != null) {
	 		%>
	 			<tr>
	   				<td><%= request.getParameter("student_id") %></td>
	   				<td><%= total_units %></td>
	    			<td><%= category_details %></td>
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