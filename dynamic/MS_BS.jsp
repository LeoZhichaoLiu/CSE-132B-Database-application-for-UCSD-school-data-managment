<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>MS_BS</title>
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
              //Connection conn = DriverManager.getConnection("jdbc:postgresql:leo?user=leo");
               Connection conn = DriverManager.getConnection(
                      "jdbc:postgresql:leo?user=leo");
            %>


            <%
            // Check if an insertion is requested        
            String action = request.getParameter("action");
                    
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
                
              PreparedStatement pstmt = conn.prepareStatement("INSERT INTO MS_BS VALUES (?, ?, ?, ?)");

              pstmt.setString(1, request.getParameter("id"));
              pstmt.setString(2, request.getParameter("major"));
              pstmt.setString(3, request.getParameter("minor"));
              pstmt.setString(4, request.getParameter("department"));
                                        
              pstmt.executeUpdate();

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
                      "UPDATE MS_BS SET major = ?, minor = ?, " +
                      "department = ? WHERE id = ?");
                  
                  pstmt.setString(1, request.getParameter("major"));
                  pstmt.setString(2, request.getParameter("minor"));
                  pstmt.setString(3, request.getParameter("department"));
                  pstmt.setString(4, request.getParameter("id"));
                  
                  int rowCount = pstmt.executeUpdate();

                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- delete --%>
            <%
              // Check if a delete is requested
              if (action != null && action.equals("delete")) {

                  conn.setAutoCommit(false);
                  
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM MS_BS WHERE id = ?");
                  
                  pstmt.setString(1, request.getParameter("id"));
                  
                  int rowCount = pstmt.executeUpdate();
                  
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM MS_BS");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>id</th>
                      <th>major</th>
                      <th>minor</th>
                      <th>department</th>
                  </tr>

                  <tr>
                      <form action="MS_BS.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <%
                   			Statement statement2 = conn.createStatement();        
                          	ResultSet rs2 = statement2.executeQuery ("select * from Student" +
         			                " where id not in ((select id from graduate) UNION" +
         			                " (select id from undergraduate) UNION (select id from ms_bs))");
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
                          <th><input value="" name="major" size="15"></th>
                          <th><input value="" name="minor" size="15"></th>
                          <%
                   				Statement statement4 = conn.createStatement();        
                   				ResultSet rs4 = statement4.executeQuery ("select * from department");
                  		   %>
                   		   <th>
                   				<select name="department">
                   				<%   while (rs4.next()) {   
                   				 	String department_name = rs4.getString("name");
                   				%>
  									<option value="<%= department_name%>"><%= department_name%></option>
  								<%  }  %>
							</select>
                   		  </th>

                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="MS_BS.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <%
                   		Statement statement3 = conn.createStatement();        
                    	ResultSet rs3 = statement3.executeQuery ("select * from Student" +
   			                " where id not in ((select id from graduate) UNION" +
   			                " (select id from undergraduate) UNION (select id from ms_bs))");
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
                    <td><input value="<%= rs.getString("major") %>" name="major"></td>
                    <td><input value="<%= rs.getString("minor") %>" name="minor"></td>
                    <%
                   		Statement statement5 = conn.createStatement();        
                   		ResultSet rs5 = statement5.executeQuery ("select * from department");
                 	%>
                   <th>
                   		<select name="department">
                   		    <option value="<%= rs.getString("department") %>"> 
                   		         <%= rs.getString("department") %></option>
                   			<%   while (rs5.next()) {   
                   				 String department_name = rs5.getString("name");
                   			%>
  								<option value="<%= department_name%>"><%= department_name%></option>
  							<%  }  %>
						</select>
                    </th>
                    <td><input type="submit" value="Update"></td>
                </form>


                <form action="MS_BS.jsp" method="get">
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