<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Grade Distribution</title>
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
        
        ResultSet four_info = null;
        ResultSet two_info = null;
        ResultSet one_info = null;
    	    	
       // when submit the form 
        if (action != null && action.equals("submit")) {

          if(!request.getParameter("course_title").equals("") && 
          !request.getParameter("year").equals("") && 
          !request.getParameter("quarter").equals("") &&
          !request.getParameter("instructor").equals("")) {
			      conn.setAutoCommit(false);
            PreparedStatement pstmt = conn.prepareStatement(
              "SELECT * FROM class_taken_in_the_past "+ 
              "WHERE course_title = ? AND year = ? AND quarter = ? AND instructor = ?");


            pstmt.setString(1, request.getParameter("course_title"));
            pstmt.setInt(2, Integer.parseInt(request.getParameter("year")));
            pstmt.setString(3, request.getParameter("quarter"));
            pstmt.setString(4, request.getParameter("instructor"));

            four_info = pstmt.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);
            }


            if(!request.getParameter("course_title").equals("") && 
            !request.getParameter("instructor").equals("")) {
			      conn.setAutoCommit(false);
            PreparedStatement pstmt = conn.prepareStatement(
              "SELECT * FROM class_taken_in_the_past "+
              "INNER JOIN grade_conversion ON class_taken_in_the_past.grade = grade_conversion.letter_grade " + 
              "WHERE course_title = ? AND instructor = ?");


            pstmt.setString(1, request.getParameter("course_title"));
            pstmt.setString(2, request.getParameter("instructor"));

            two_info = pstmt.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);
            }

            if(!request.getParameter("course_title").equals("")) {
			      conn.setAutoCommit(false);
            PreparedStatement pstmt = conn.prepareStatement(
              "SELECT * FROM class_taken_in_the_past "+
              "INNER JOIN grade_conversion ON class_taken_in_the_past.grade = grade_conversion.letter_grade " + 
              "WHERE course_title = ?");
              
            pstmt.setString(1, request.getParameter("course_title"));

            one_info = pstmt.executeQuery();
            conn.commit();
            conn.setAutoCommit(true);
            }

        }

    %> 

            <%-- statement --%>


            <%-- presentation --%>
            <h2>Input</h2>
             <table>
         	<tr>
               <th>Course</th>
               <th>Year</th>
               <th>Quarter</th>
               <th>Instructor</th>
        	 </tr>
        	 <tr>

			             <form action="ms3_3a.jsp" method="POST">
			              
			              <%
                   			Statement statement2 = conn.createStatement();        
                   			ResultSet rs2 = statement2.executeQuery ("select * from course");
                   		  %>
                   	      <th>
                   			 <select name="course_title">
                   			 <%   while (rs2.next()) {   
                   			 	  String course_id = rs2.getString("Course_Name");
                   			 %>
  							 	<option value="<%= course_id%>"><%= course_id%></option>
  							 <%  }  %>
							 </select>
                  		  </th>
                  		  
                          <th><input value="" type = "number" name="year" min="1960" max="2022"></th>
                          
                  		  <th><div>
                             <input type="radio" name="quarter" value="FA">FALL
				             <br>
					         <input type="radio" name="quarter" value="WI">Winter
					         <br>
					         <input type="radio" name="quarter" value="SP">Spring
					      </div></th>
 
                          <%
                   			Statement statement4 = conn.createStatement();        
                   			ResultSet rs4 = statement4.executeQuery ("select * from faculty");
                  		  %>
                   		  <th>
                   		  <select name="instructor">
                   			<%   while (rs4.next()) {   
                   				 String instructor_name = rs4.getString("name");
                   			%>
  								<option value="<%= instructor_name%>"><%= instructor_name%></option>
  							<%  }  %>
						  </select>
                  		  </th>        
			             
                          <th><button type="submit" name="action" value="submit">Submit</button><th>
                      </form>
              </tr>
              </table>




       <%-- display report --%> 
       <h3> Information </h3> 
       <p> <%= request.getParameter("course_title") %> <%= request.getParameter("year") %> <%= request.getParameter("quarter") %> <%= request.getParameter("instructor") %> </p>
			
      <h2>course id - year - quarter - instructor</h2>
      
      <table>
	 	 <tr>
	   		 <th>A number</th>
	   		 <th>B number</th>
         <th>C number</th>
	   		 <th>D number</th>
         <th>other number</th>
	    </tr>
	 	 
	 	<%
        Integer a = 0;
        Integer b = 0;
        Integer c = 0;
        Integer d = 0;
        Integer other = 0;

	  		if (four_info != null) {
	  			if (four_info.isBeforeFirst()) {
					while(four_info.next()) { 
            if(four_info.getString("grade").charAt(0) == 'A'){
              a++;
            } else if(four_info.getString("grade").charAt(0) == 'B'){
              b++;
            } else if(four_info.getString("grade").charAt(0) == 'C'){
              c++;
            } else if(four_info.getString("grade").charAt(0) == 'D'){
              d++;
            } else {
              other++;
            } 

					}
          %>
          <tr>
					   		<td><%=a %></td>
					   		<td><%=b %></td>
					    	<td><%=c %></td>
                <td><%=d %></td>
					    	<td><%=other %></td>
						</tr>
            <%

				}	
	  		}
	  %>
	</table>





			<h2>course id - instructor</h2>
<table>
	 	 <tr>
	   		 <th>A number</th>
	   		 <th>B number</th>
         <th>C number</th>
	   		 <th>D number</th>
         <th>other number</th>
	    </tr>
	 	 
	 	<%
        Integer a_overall = 0;
        Integer b_overall = 0;
        Integer c_overall = 0;
        Integer d_overall = 0;
        Integer other_overall = 0;

	  		if (two_info != null) {
	  			if (two_info.isBeforeFirst()) {
					while(two_info.next()) { 
            if(two_info.getString("grade").charAt(0) == 'A'){
              a_overall++;
            } else if(two_info.getString("grade").charAt(0) == 'B'){
              b_overall++;
            } else if(two_info.getString("grade").charAt(0) == 'C'){
              c_overall++;
            } else if(two_info.getString("grade").charAt(0) == 'D'){
              d_overall++;
            } else {
              other_overall++;
            } 

					}
          %>
          <tr>
					   		<td><%=a_overall %></td>
					   		<td><%=b_overall %></td>
					    	<td><%=c_overall %></td>
                <td><%=d_overall %></td>
					    	<td><%=other_overall %></td>
						</tr>
            <%

				}	
	  		}
	  %>
	</table>

      <h3>grade point average</h3>
      <%
      PreparedStatement pstmt = conn.prepareStatement(
					"SELECT AVG(number_grade)  as average FROM class_taken_in_the_past " +
          "INNER JOIN grade_conversion ON class_taken_in_the_past.grade = grade_conversion.letter_grade " +
          "WHERE course_title = ? AND instructor = ?");

            pstmt.setString(1, request.getParameter("course_title"));
            pstmt.setString(2, request.getParameter("instructor"));

        Double average = 0.0;

	      ResultSet average_info = pstmt.executeQuery();
        if (average_info != null) {
	  			if (average_info.isBeforeFirst()) {
					while(average_info.next()) { 
		  				 average = average_info.getDouble("average");
					}
	  			}
		  }

       %>
       <h3><%=average %></h3>
       
      

			<h2>course id</h2>
      <table>
	 	 <tr>
	   		 <th>A number</th>
	   		 <th>B number</th>
         <th>C number</th>
	   		 <th>D number</th>
         <th>other number</th>
	    </tr>
	 	 
	 	<%
        Integer a_overall1 = 0;
        Integer b_overall1 = 0;
        Integer c_overall1 = 0;
        Integer d_overall1 = 0;
        Integer other_overall1 = 0;

	  		if (one_info != null) {
	  			if (one_info.isBeforeFirst()) {
					while(one_info.next()) { 
            if(one_info.getString("grade").charAt(0) == 'A'){
              a_overall1++;
            } else if(one_info.getString("grade").charAt(0) == 'B'){
              b_overall1++;
            } else if(one_info.getString("grade").charAt(0) == 'C'){
              c_overall1++;
            } else if(one_info.getString("grade").charAt(0) == 'D'){
              d_overall1++;
            } else {
              other_overall1++;
            } 

					}
          %>
          <tr>
					   		<td><%=a_overall1 %></td>
					   		<td><%=b_overall1 %></td>
					    	<td><%=c_overall1 %></td>
                <td><%=d_overall1 %></td>
					    	<td><%=other_overall1 %></td>
						</tr>
            <%

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