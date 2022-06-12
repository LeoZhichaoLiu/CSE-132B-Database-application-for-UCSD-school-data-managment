<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>concentration</title>
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
               Connection conn = DriverManager.getConnection("jdbc:postgresql:leo?user=leo");
               //Connection conn = DriverManager.getConnection(
               // "jdbc:postgresql:trition?user=postgres&password=Djp7052!");
            %>



            <%-- insert --%>
            <%
            // Check if an insertion is requested        
            String action = request.getParameter("action");
                    
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
                
              PreparedStatement pstmt = conn.prepareStatement("INSERT INTO concentration" +
                    "(concentration_name, course_info, req_units, req_gpa) VALUES (?, ?, ?, ?)");
              
			  boolean valid_input = true;
              
              if (!request.getParameter("course_info").equals("")) {
              	String[] con_list = request.getParameter("course_info").split(",");
 	    	 	for (String item : con_list) {
 	    			PreparedStatement p5 = conn.prepareStatement("select * from course WHERE " +
                  	       "course_name = ? ");
              		p5.setString(1, item);
              		ResultSet r = p5.executeQuery();
              		if (!r.next()) {
              		
            		%>
              		<b style="font-size:25px"> Course <%= item %> is not registered! Please register first!"</b>
             	    <%  
                 	valid_input = false;
                 	break;
              	    }
 	    	     }
              }
              
              
              if (valid_input) {
              	pstmt.setString(1, request.getParameter("concentration_name"));
              	pstmt.setString(2, request.getParameter("course_info"));
              	pstmt.setInt(3, Integer.parseInt(request.getParameter("req_units")));
              	pstmt.setString(4, request.getParameter("req_gpa"));                     
              	pstmt.executeUpdate();
              }
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
                      "UPDATE concentration SET concentration_name = ?, course_info = ?, req_units = ?, req_gpa = ?" +
                      "WHERE unique_id = ?");
                  
                  pstmt.setString(1, request.getParameter("concentration_name"));
                  pstmt.setString(2, request.getParameter("course_info"));
                  pstmt.setInt(3, Integer.parseInt(request.getParameter("req_units")));
                  pstmt.setString(4, request.getParameter("req_gpa"));
                  
                  
                  pstmt.setInt(5, Integer.parseInt(request.getParameter("unique_id")));

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
                  
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM concentration"  +
                                     " WHERE unique_id = ?");
                  
                  pstmt.setInt(1, Integer.parseInt(request.getParameter("unique_id")));
                  
                  
                  int rowCount = pstmt.executeUpdate();
                  
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM concentration");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>concenration_name</th>
                      <th>courses</th>
                      <th>min units</th>
                      <th>min gpa</th>
                  </tr>

                  <tr>
                      <form action="concentration.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          
                          <th><input value="" name="concentration_name" size="15"></th>
                          
                          <th><input value="" name="course_info" size="60"></th>
                   		
                   		 <td>
                			<input type="number" name="req_units" value="0" min="0" max="100" >
                		 </td>
                		  
                		 <td>
                		    <input value="" name="req_gpa" size=3 >
                		 </td>  
                        <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="concentration.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <input type="hidden" value="<%= rs.getInt("unique_id") %>" name="unique_id">
                    <td><input value="<%= rs.getString("concentration_name") %>" name="concentration_name"></td>
                    <th>
                   		<input value="<%= rs.getString("course_info") %>" name="course_info">
                   </th>
                   <td>
                	<input type="number" name="req_units" value="<%=rs.getInt("req_units") %>">
               		</td>
               		<td>
                	<input name="req_gpa" value="<%=rs.getString("req_gpa") %>">
                	</td>
                    <td><input type="submit" value="Update"></td>
                </form>
                
                <form action="concentration.jsp" method="get">
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