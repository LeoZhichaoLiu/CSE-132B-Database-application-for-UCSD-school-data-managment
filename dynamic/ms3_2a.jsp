<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Student's class schedule</title>
</head>


<body>
	<jsp:include page="index.html" />
	<table>
	<tr>
	<td>

    <%
    try {
        DriverManager.registerDriver(new org.postgresql.Driver());
    
        //Connection conn = DriverManager.getConnection(
        //       "jdbc:postgresql:trition?user=postgres&password=Djp7052!");
        Connection conn = DriverManager.getConnection("jdbc:postgresql:leo?user=leo");
        
        
        String action = request.getParameter("action");
        
        ResultSet class_info = null;
        ResultSet student_info = null;

        
        // Select all students' information
        conn.setAutoCommit(false);
    	PreparedStatement pstmt2 = conn.prepareStatement(
        "SELECT DISTINCT student.ssn, student.first_name, student.last_name, student.middle_name "+
 "FROM student INNER JOIN course_enrollment ON student.id = course_enrollment.id");
    	
    	student_info = pstmt2.executeQuery();
    	conn.commit();
    	conn.setAutoCommit(true);
    	
    	
       // when submit the form 
        if (action != null && action.equals("submit")) {
        	
            conn.setAutoCommit(false);
            PreparedStatement pstmt = conn.prepareStatement(
				"WITH my_class AS ( " + 
        "SELECT DISTINCT w.course_name, w.section_id, w.year, w.quarter, w.day, w.type, " +  
        "w.mandatory, w.start_time, w.end_time, w.building, w.room " + 
        "FROM weekly_meeting w, student s, course_enrollment c " + 
        "WHERE c.id = s.id AND s.ssn = ? " + 
        "AND c.course_name = w.course_name AND " +  
        "c.section_id = w.section_id AND w.year = 2022 AND w.quarter = 'SP' " + 
        "), " + 
        "not_my_class AS ( " + 
        "SELECT w.course_name, w.section_id, w.year, w.quarter, w.day, w.type, " + 
        "w.mandatory, w.start_time, w.end_time, w.building, w.room " + 
        "FROM weekly_meeting w " + 
        "WHERE w.course_name NOT IN (SELECT course_name FROM my_class) " + 
        "AND w.year = 2022 AND w.quarter ='SP' " + 
        "), " + 
        "section_conflict AS ( " + 
        "SELECT DISTINCT n.course_name as conflicting_cn, c1.class_title as conflicting_ct, " + 
        "n.section_id as conflicting_s, m.course_name as conflicted_cn, c2.class_title as conflicted_ct, " + 
        "m.section_id as conflicted_s " + 
        "FROM my_class m, not_my_class n, class c1, class c2 " + 
        "WHERE c1.course_name = n.course_name AND c2.course_name = m.course_name " + 
        "AND n.day = m.day AND n.mandatory = TRUE AND m.mandatory = TRUE " + 
        "AND (n.start_time::time, n.end_time::time) OVERLAPS (m.start_time::time, m.end_time::time)) " + 
        "SELECT s.conflicting_cn, s.conflicting_ct, s.conflicted_cn, s.conflicted_ct, count(*) " + 
        "FROM section_conflict s " + 
        "GROUP BY s.conflicting_cn, s.conflicting_ct, s.conflicted_cn, s.conflicted_ct " + 
        "HAVING count(*) = ( " + 
        "SELECT count(c.section_id)  " + 
        "FROM class c " + 
        "WHERE s.conflicting_cn = c.course_name AND s.conflicting_ct = c.class_title AND  " + 
        "c.year = 2022 AND c.quarter ='SP')");
		
            pstmt.setString(1, request.getParameter("ssn"));
            class_info = pstmt.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);

        }

    %> 

            <%-- presentation --%> 
            <h2>Choose Enrolled Student</h2>
			<form action="ms3_2a.jsp" method="POST">
		
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



       <%-- display report --%> 

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
 
		  <h2>Class By Quarter</h2>
		  <h3><%= first %> <%= middle %> <%= last %> <%= ssn %> </h3>
	

		 <table>
	 	 <tr>
	   		 <th>Course Name Conflicting</th>
	   		 <th>Class Tittle Conflicting</th>
         <th>Course Name Conflicted With</th>
         <th>Class Title Conflicted With</th>

	    </tr>
	 	 
	 	<%

	  		if (class_info != null) {
	  			if (class_info.isBeforeFirst()) {
					while(class_info.next()) { 
        

						%>
				
		  				<tr>
					   		<td><%=class_info.getString("conflicting_cn") %></td>
					   		<td><%=class_info.getString("conflicting_ct") %></td>
                 <td><%=class_info.getString("conflicted_cn") %></td>
					   		<td><%=class_info.getString("conflicted_ct") %></td>
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