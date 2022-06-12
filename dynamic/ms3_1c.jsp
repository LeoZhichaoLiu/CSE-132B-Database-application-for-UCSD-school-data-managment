<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Student's grade report</title>
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
        ResultSet quarter_gpa_info = null;
        ResultSet overall_gpa_info = null;

        String gpa_year = null;
        String gpa_quarter = null;
        Double quarter_gpa;
        Double cumulative_gpa;
        
        // Select all students' information
        conn.setAutoCommit(false);
    	PreparedStatement pstmt2 = conn.prepareStatement(
        "SELECT DISTINCT student.ssn, student.first_name, student.last_name, student.middle_name "+
 "FROM student INNER JOIN class_taken_in_the_past ON student.id = class_taken_in_the_past.id");
    	
    	student_info = pstmt2.executeQuery();
    	conn.commit();
    	conn.setAutoCommit(true);
    	
    	
       // when submit the form 
        if (action != null && action.equals("submit")) {
        	
            conn.setAutoCommit(false);
            PreparedStatement pstmt = conn.prepareStatement(
				"SELECT class.Course_Name, class.Section_id, class.Year, class.Quarter, "+
        "class.Class_Title, class.Enrollment_Limit, class.Instructor, class_taken_in_the_past.units, " +
        "class_taken_in_the_past.grade FROM student "+
        "INNER JOIN class_taken_in_the_past ON student.id = class_taken_in_the_past.id " +
        "INNER JOIN class ON class_taken_in_the_past. course_title = class.Course_Name AND " + 
        "class_taken_in_the_past.year =  class.year AND " +
        "class_taken_in_the_past.quarter = class.quarter AND " +
        "class_taken_in_the_past.section_id = class.section_id AND " +
        "class_taken_in_the_past.instructor = class.instructor " + 
        "WHERE student.id = (select id from student where ssn = ?) " +
        "ORDER BY class.year, class.quarter DESC");
		
            pstmt.setString(1, request.getParameter("ssn"));
            class_info = pstmt.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);


                      conn.setAutoCommit(false);
            PreparedStatement pstmt4 = conn.prepareStatement(
        "SELECT class.year, class.quarter, SUM(grade_conversion.number_grade * units) as quarter_gpa, "+
        "SUM(units) as quarter_units FROM student "+
        "INNER JOIN class_taken_in_the_past ON student.id = class_taken_in_the_past.id " +
        "INNER JOIN grade_conversion ON class_taken_in_the_past.grade = grade_conversion.letter_grade "+
        "INNER JOIN class ON class_taken_in_the_past. course_title = class.Course_Name AND " + 
        "class_taken_in_the_past.year =  class.year AND " +
        "class_taken_in_the_past.quarter = class.quarter AND " +
        "class_taken_in_the_past.section_id = class.section_id AND " +
        "class_taken_in_the_past.instructor = class.instructor " + 
        "WHERE student.id = (select id from student where ssn = ?) " +
        "GROUP BY class.year, class.quarter");
    
            pstmt4.setString(1, request.getParameter("ssn"));
            
            quarter_gpa_info = pstmt4.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);



            conn.setAutoCommit(false);
            PreparedStatement pstmt5 = conn.prepareStatement(
        "SELECT SUM(grade_conversion.number_grade * units) as overall_gpa, SUM(units) as overall_units FROM student "+
        "INNER JOIN class_taken_in_the_past ON student.id = class_taken_in_the_past.id " +
        "INNER JOIN grade_conversion ON class_taken_in_the_past.grade = grade_conversion.letter_grade "+
        "INNER JOIN class ON class_taken_in_the_past. course_title = class.Course_Name AND " + 
        "class_taken_in_the_past.year =  class.year AND " +
        "class_taken_in_the_past.quarter = class.quarter AND " +
        "class_taken_in_the_past.section_id = class.section_id AND " + 
        "class_taken_in_the_past.instructor = class.instructor " +
        "WHERE student.id = (select id from student where ssn = ?)");
    
            pstmt5.setString(1, request.getParameter("ssn"));
            
            overall_gpa_info = pstmt5.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);


        }

    %> 

            <%-- presentation --%> 
            <h2>Choose Enrolled Student</h2>
			<form action="ms3_1c.jsp" method="POST">
		
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
	   		 <th>Course Name</th>
	   		 <th>Section</th>
         <th>Year</th>
	   		 <th>Quarter</th>
         <th>Class Title</th>
	   		 <th>Enrollment Limit</th>
        <th>Instructor</th>
	    	 <th>Units</th>
         <th>Grade</th>
	    </tr>
	 	 
	 	<%
	  		if (class_info != null) {
	  			if (class_info.isBeforeFirst()) {
					while(class_info.next()) { 
						%>
				
		  				<tr>
					   		<td><%=class_info.getString("course_name") %></td>
					   		<td><%=class_info.getInt("section_id") %></td>
					    	<td><%=class_info.getInt("year") %></td>
                <td><%=class_info.getString("quarter") %></td>
					    	<td><%=class_info.getString("class_title") %></td>
                <td><%=class_info.getInt("enrollment_limit") %></td>
					   		<td><%=class_info.getString("instructor") %></td>
					    	<td><%=class_info.getInt("units") %></td>
                <td><%=class_info.getString("grade") %></td>
						</tr>
						
					    <%
					}
				}	
	  		}
	  %>
	</table>




  <h2>Quarter GPA</h2>
  <table>
	 	 <tr>
         <th>Year</th>
	   		 <th>Quarter</th>
         <th>GPA</th>
	    </tr>
	 	 
	 	<%
	  		if (quarter_gpa_info != null) {
	  			if (quarter_gpa_info.isBeforeFirst()) {
					while(quarter_gpa_info.next()) { 
            quarter_gpa = quarter_gpa_info.getDouble("quarter_gpa") / quarter_gpa_info.getInt("quarter_units");

						%>
				
		  				<tr>
					   		<td><%=quarter_gpa_info.getInt("year") %></td>
					   		<td><%=quarter_gpa_info.getString("quarter") %></td>
					    	<td><%=quarter_gpa %></td>
						</tr>
						
					    <%
					}
				}	
	  		}
	  %>
	</table>


  <h2>Cul. GPA</h2>
  <%
	  		if (overall_gpa_info != null) {
	  			if (overall_gpa_info.isBeforeFirst()) {
					while(overall_gpa_info.next()) { 
            Double overall_gpa = overall_gpa_info.getDouble("overall_gpa") / overall_gpa_info.getInt("overall_units");

						%>
				
		  				<tr>
					   		<td><%=overall_gpa %></td>
						</tr>
						
					    <%
					}
				}	
	  		}
	  %>





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