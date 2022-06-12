<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Student</title>
</head>

<body>
  <jsp:include page="index.html" />
    <table>
        <tr>

            <td>
    
            <%
            try {
              // Load postgres Driver class file
              DriverManager.registerDriver(new org.postgresql.Driver());
    
              // Make a connection to the postgres datasource 
               Connection conn = DriverManager.getConnection(
                      "jdbc:postgresql:leo?user=leo");
            %>


            <%
            // Check if an insertion is requested        
            String action = request.getParameter("action");
                    
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
                
              PreparedStatement pstmt = conn.prepareStatement("INSERT INTO student VALUES (?, ?, ?, ?, ?, ?, ?)");

              pstmt.setString(1, request.getParameter("id"));
              pstmt.setString(2, request.getParameter("first_name"));
              pstmt.setString(3, request.getParameter("middle_name"));
              pstmt.setString(4, request.getParameter("last_name"));
              pstmt.setString(5, request.getParameter("ssn"));   
              pstmt.setString(6, request.getParameter("residency"));
              pstmt.setBoolean(7, Boolean.parseBoolean(request.getParameter("enrolled")));
                                        
              pstmt.executeUpdate();
              // conn.commit();
              conn.setAutoCommit(false);
              conn.setAutoCommit(true);                   
            }
            %>

            <%-- update --%>
            <%
              // Check if an update is requested
              if (action != null && action.equals("update")) {

                  conn.setAutoCommit(false);

                  PreparedStatement pstmt = conn.prepareStatement(
                      "UPDATE student SET first_name = ?, middle_name = ?, " +
                      "last_name = ?, ssn = ?, residency = ?, enrolled = ? WHERE id = ?");
                  
                  pstmt.setString(1, request.getParameter("first_name"));
                  pstmt.setString(2, request.getParameter("middle_name"));
                  pstmt.setString(3, request.getParameter("last_name"));
                  pstmt.setString(4, request.getParameter("ssn"));
                  pstmt.setString(5, request.getParameter("residency"));
                  pstmt.setBoolean(6, Boolean.parseBoolean(request.getParameter("enrolled")));
                  pstmt.setString(7, request.getParameter("id"));
                  
                  int rowCount = pstmt.executeUpdate();

                  // conn.commit();
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- delete --%>
            <%
              // Check if a delete is requested
              if (action != null && action.equals("delete")) {

                  conn.setAutoCommit(false);
                  
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM student WHERE id = ?");
                  
                  String student_id = request.getParameter("id");
                  pstmt.setString(1, student_id);
                  
                  int rowCount = pstmt.executeUpdate();
                  
                  PreparedStatement delete_undergrad = conn.prepareStatement(
                      	"DELETE FROM undergraduate WHERE id = ?");
                  PreparedStatement delete_grad = conn.prepareStatement(
                      	"DELETE FROM graduate WHERE id = ?");
                  PreparedStatement delete_MSBS = conn.prepareStatement(
                        	"DELETE FROM MS_BS WHERE id = ?");
                  PreparedStatement delete_period = conn.prepareStatement(
                        	"DELETE FROM period WHERE id = ?");
                  PreparedStatement delete_probation = conn.prepareStatement(
                        	"DELETE FROM probation WHERE id = ?");
                  PreparedStatement delete_previous_degree = conn.prepareStatement(
                        	"DELETE FROM previous_degree WHERE id = ?");
                  PreparedStatement delete_club = conn.prepareStatement(
                      	"DELETE FROM participate_club WHERE id = ?");
                  PreparedStatement delete_committee = conn.prepareStatement(
                        	"DELETE FROM thesis_committee WHERE id = ?");
                  
                  PreparedStatement delete_class_taken = conn.prepareStatement(
                      	"DELETE FROM class_taken_in_the_past WHERE id = ?");
                  
                  PreparedStatement delete_enrolled = conn.prepareStatement(
                        	"DELETE FROM course_enrollment WHERE id = ?");
                  
                  
                  delete_undergrad.setString(1, student_id);
                  delete_grad.setString(1, student_id);
                  delete_MSBS.setString(1, student_id);
                  delete_period.setString(1, student_id);
                  delete_probation.setString(1, student_id);
                  delete_previous_degree.setString(1, student_id);
                  delete_club.setString(1, student_id);
                  delete_committee.setString(1, student_id);
                  delete_class_taken.setString(1, student_id);
                  delete_enrolled.setString(1, student_id);
                  
                  delete_undergrad.executeUpdate();
                  delete_grad.executeUpdate();
                  delete_MSBS.executeUpdate();
                  delete_period.executeUpdate();
                  delete_probation.executeUpdate();
                  delete_previous_degree.executeUpdate();
                  delete_club.executeUpdate();
                  delete_committee.executeUpdate();
                  delete_class_taken.executeUpdate();
                  delete_enrolled.executeUpdate();
                  
                  // conn.commit();
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM student");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>id</th>
                      <th>first name</th>
                      <th>middle name </th>
                      <th>last name</th>
                      <th>ssn</th>
                      <th>residency</th>
                      <th>enrollment</th>
                  </tr>

                  <tr>
                      <form action="Student.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <th><input value="" name="id" size="10"></th>
                          <th><input value="" name="first_name" size="15"></th>
                          <th><input value="" name="middle_name" size="15"></th>
                          <th><input value="" name="last_name" size="15"></th>
                          <th><input value="" name="ssn" size="10"></th>
                          <th><div>
				       		<br>
					   		<input type="radio" name="residency" value="California">California
					   		<br>
					   		<input type="radio" name="residency" value="Out-Of-States" checked>Out-Of-States
					   		<br>
					   		<input type="radio" name="residency" value="International" checked>International
						  </div></th>
                          <th><div>
				       		<br>
					   		<input type="radio" name="enrolled" value="True">Yes
					   		<br>
					   		<input type="radio" name="enrolled" value="False" checked>No
						  </div></th>
                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="Student.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <td><input value="<%= rs.getString("id") %>" name="id"></td>
                    <td><input value="<%= rs.getString("first_name") %>" name="first_name"></td>
                    <td><input value="<%= rs.getString("middle_name") %>" name="middle_name"></td>
                    <td><input value="<%= rs.getString("last_name") %>" name="last_name"></td>
                    <td><input value="<%= rs.getString("ssn") %>" name="ssn"></td>
                    <td>
						<br>
						<input type="radio" name="residency" value="California"  <%=rs.getString("residency").equals("California") ? "checked" : ""  %>  >California
						<br>
						<input type="radio" name="residency" value="Out-Of-States" <%=rs.getString("residency").equals("Out-Of-States") ? "checked" : ""  %>  >Out-Of-States
						<br>
						<input type="radio" name="residency" value="International" <%=rs.getString("residency").equals("International") ? "checked" : ""  %>  >International
			    	</td>
                    <td>
						<br>
						<input type="radio" name="enrolled" value="True"  <%=rs.getBoolean("enrolled") == true ? "checked" : ""  %>  >Yes
						<br>
						<input type="radio" name="enrolled" value="False" <%=rs.getBoolean("enrolled") == false ? "checked" : ""  %>  >No
						<br>
			    	</td>
                    <td><input type="submit" value="Update"></td>
                </form>


                <form action="Student.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getString("id") %>" name="id">
                    <td><input type="submit" value="Delete"></td>
                </form>
            </tr>
            
            <%
              }
            %>
          </table>

            <%-- close connectivity --%>
            <%
              rs.close();
              statement.close();
              conn.close();
              } catch (SQLException sqle) {
                  out.println(sqle.getMessage());
              } catch (Exception e) {
                  out.println(e.getMessage());
              }
            %>
                
            </td>
        </tr>
    </table>
</body>
</html>