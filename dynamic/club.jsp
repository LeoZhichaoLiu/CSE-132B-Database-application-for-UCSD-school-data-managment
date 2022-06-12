<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Club</title>
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
                
              PreparedStatement pstmt = conn.prepareStatement("INSERT INTO club VALUES (?, ?)");

              pstmt.setString(1, request.getParameter("club_name"));
              pstmt.setString(2, request.getParameter("type"));
                                        
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
                      "UPDATE club SET type = ? WHERE club_name = ?");
                  
                  pstmt.setString(1, request.getParameter("type"));
                  pstmt.setString(2, request.getParameter("club_name"));
                  
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
                  
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM club WHERE club_name = ?");
                  
                  pstmt.setString(1, request.getParameter("club_name"));
                  
                  int rowCount = pstmt.executeUpdate();
                  
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM club");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>club_name</th>
                      <th>type</th>
                  </tr>

                  <tr>
                      <form action="club.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <th><input value="" name="club_name" size="15"></th>
                          <th><input value="" name="type" size="15"></th>
                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="club.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <td><input value="<%= rs.getString("club_name") %>" name="club_name"></td>
                    <td><input value="<%= rs.getString("type") %>" name="type"></td>
                    <td><input type="submit" value="Update"></td>
                </form>


                <form action="club.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getString("club_name") %>" name="club_name">
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