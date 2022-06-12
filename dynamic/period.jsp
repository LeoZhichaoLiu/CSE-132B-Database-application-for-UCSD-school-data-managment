<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Period Info Submission</title>
</head>

<body>
<jsp:include page="index.html" />
    <table>  
        <tr>
            <td>
            <%-- Set the scripting language to Java and --%>
            <%-- Import the java.sql package --%>
            <%@ page language="java" import="java.sql.*" %>
    



            <%-- open connectivity --%>
            <%
                try {
                    // Load postgres Driver class file
                    DriverManager.registerDriver(new org.postgresql.Driver());
    
                    // Make a connection to the postgres datasource 
                    Connection conn = DriverManager.getConnection(
                      "jdbc:postgresql:leo?user=leo");
            %>



            <%-- insert --%>
            <%
            // Check if an insertion is requested        
            String action = request.getParameter("action");
                    
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
                
              PreparedStatement pstmt = conn.prepareStatement(
                "INSERT INTO period(id, start_time, end_time) VALUES (?, ?, ?)");

              pstmt.setString(1, request.getParameter("id"));
              pstmt.setString(2, request.getParameter("start_time"));
              pstmt.setString(3, request.getParameter("end_time"));
                                        
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
                      "UPDATE period SET start_time = ?, " +
                      "end_time = ? WHERE unique_id = ?");

                  pstmt.setString(1, request.getParameter("start_time"));
                  pstmt.setString(2, request.getParameter("end_time"));
                  pstmt.setInt(3, Integer.parseInt(request.getParameter("unique_id")));


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
                  
                  PreparedStatement pstmt = conn.prepareStatement(
                    "DELETE FROM period WHERE unique_id = ?");

                  pstmt.setInt(1, Integer.parseInt(request.getParameter("unique_id")));

                  int rowCount = pstmt.executeUpdate();
                  
                  // conn.commit();
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM period");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>id</th>
                      <th>start_time</th>
                      <th>end_time</th>

                  </tr>

                  <tr>
                      <form action="period.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <%
                   			Statement statement2 = conn.createStatement();        
                   			ResultSet rs2 = statement2.executeQuery ("select * from Student");
                   			%>
                   			<th>
                   			<select name="id">
                   				<%   while (rs2.next()) {   
                   					 String student_id = rs2.getString("id");
                   				%>
  									<option value="<%= student_id%>"><%= student_id%></option>
  								<%  }  %>
							</select>
                   			</th>
                          <th><input value="" name="start_time" size="15"></th>
                          <th><input value="" name="end_time" size="15"></th>
                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="period.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <input type="hidden" value="<%= rs.getInt("unique_id") %>" name="unique_id">
                    <%
                   		Statement statement3 = conn.createStatement();        
                   		ResultSet rs3 = statement3.executeQuery ("select * from student");
                 	%>
                  	<th>
                  	 		<select name="id">
                   		    <option value="<%= rs.getString("id") %>"> 
                   		         <%= rs.getString("id") %></option>
                   			<%   while (rs3.next()) {   
                   				 String student_id = rs3.getString("id");
                   			%>
  								<option value="<%= student_id%>"><%= student_id%></option>
  							<%  }  %>
						</select>
                   	</th>
                    <td><input value="<%= rs.getString("start_time") %>" name="start_time"></td>
                    <td><input value="<%= rs.getString("end_time") %>" name="end_time"></td>
                    <td><input type="submit" value="Update"></td>
                </form>

                <form action="period.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getInt("unique_id") %>" name="unique_id">
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