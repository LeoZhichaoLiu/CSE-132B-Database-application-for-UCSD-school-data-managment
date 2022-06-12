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
              "SELECT * FROM CPQG WHERE course_title = ? AND year = ? AND quarter = ? AND instructor = ?");


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
              "SELECT * FROM CPG WHERE course_title = ? AND instructor = ? ");


            pstmt.setString(1, request.getParameter("course_title"));
            pstmt.setString(2, request.getParameter("instructor"));

            two_info = pstmt.executeQuery();
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

			             <form action="ms5.jsp" method="POST">
			              
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

	  		if (four_info != null) {
	  			if (four_info.isBeforeFirst()) {
					while(four_info.next()) { 

          %>
          <tr>
					   		<td><%=four_info.getInt("count_a") %></td>
					   		<td><%=four_info.getInt("count_b") %></td>
					    	<td><%=four_info.getInt("count_c") %></td>
                <td><%=four_info.getInt("count_d") %></td>
					    	<td><%=four_info.getInt("count_other") %></td>
						</tr>
            <%
          }
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


	  		if (two_info != null) {
	  			if (two_info.isBeforeFirst()) {
					while(two_info.next()) { 
          %>
          <tr>
					   		<td><%=two_info.getInt("count_a") %></td>
					   		<td><%=two_info.getInt("count_b") %></td>
					    	<td><%=two_info.getInt("count_c")%></td>
                <td><%=two_info.getInt("count_d") %></td>
					    	<td><%=two_info.getInt("count_other") %></td>
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