<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Degree</title>
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
                
              PreparedStatement pstmt = conn.prepareStatement("INSERT INTO degree VALUES (?, ?, ?, ?)");
              
              
              boolean valid_input = true;
              
              if (!request.getParameter("concentration").equals("")) {
              	String[] con_list = request.getParameter("concentration").split(",");
 	    	 	for (String item : con_list) {
 	    			PreparedStatement p5 = conn.prepareStatement("select * from concentration WHERE " +
                  	       "concentration_name = ? ");
              		p5.setString(1, item);
              		ResultSet r = p5.executeQuery();
              		if (!r.next()) {
              		
            		%>
              		<b style="font-size:25px"> Concentration <%= item %> is not registered! Please register first!"</b>
             	    <%  
                 	valid_input = false;
                 	break;
              	    }
 	    	     }
              }
              
              if (!request.getParameter("category").equals("")) {
                	String[] con_list = request.getParameter("category").split(",");
   	    	 	for (String item : con_list) {
   	    			PreparedStatement p5 = conn.prepareStatement("select * from category WHERE " +
                    	       "category_name = ? ");
                    p5.setString(1, item);
                    ResultSet r = p5.executeQuery();
                	if (!r.next()) {
                		
              		%>
                	<b style="font-size:25px"> Category <%= item %> is not registered! Please register first!"</b>
               	    <%  
                   	valid_input = false;
                   	break;
                	}
   	    	     }
              }
              
              
              if (valid_input) {
              pstmt.setString(1, request.getParameter("degree_name"));
              pstmt.setString(2, request.getParameter("type"));
              
              pstmt.setString(3, request.getParameter("category"));
              pstmt.setString(4, request.getParameter("concentration"));
                         
              pstmt.executeUpdate();
              }
              
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
                      "UPDATE degree SET category = ?, " +
                      "concentration = ? WHERE degree_name = ? AND type = ?");
                  
                  
                  pstmt.setString(1, request.getParameter("category"));
                  pstmt.setString(2, request.getParameter("concentration"));
                  pstmt.setString(3, request.getParameter("degree_name"));
                  pstmt.setString(4, request.getParameter("type"));

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
                  
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM degree WHERE degree_name = ? AND type = ?");
                  
                  pstmt.setString(1, request.getParameter("degree_name"));
                  pstmt.setString(2, request.getParameter("type"));
                  
                  int rowCount = pstmt.executeUpdate();
                  
                  // conn.commit();
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM degree");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>degree_name</th>
                      <th>type</th>
                      <th>category </th>
                      <th>concentration</th>
                  </tr>

                  <tr>
                      <form action="degree.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <th><input value="" name="degree_name" size="10"></th>
                          <th><div>
						 	 <br>
							<input type="radio" name="type" value="BS" checked>BS
							<br>
							<input type="radio" name="type" value="BA">BA
							<br>
							<input type="radio" name="type" value="MS">MS
							<br>
							<input type="radio" name="type" value="PHD">PHD
							<br>
						  </div></th>
						  
						   <th><input value="" name="category" size="40"></th>
                           <th><input value="" name="concentration" size="40"></th>
                            
                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="degree.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <td><input value="<%= rs.getString("degree_name") %>" name="degree_name"></td>
                    <td>
						<br>
						<input type="radio" name="type" value="BS" <%=rs.getString("type").equals("BS") ? "checked" : ""  %>  >BS
						<br>
						<input type="radio" name="type" value="BA" <%=rs.getString("type").equals("BA") ? "checked" : ""  %>  >BA
						<br>
						<input type="radio" name="type" value="MS" <%=rs.getString("type").equals("MS") ? "checked" : ""  %>  >MS
						<br>
						<input type="radio" name="type" value="PHD" <%=rs.getString("type").equals("PHD") ? "checked" : ""  %>  >PHD
				    </td>
				    
				    <td><input value="<%= rs.getString("category") %>" name="category"></td>   
                    <td><input value="<%= rs.getString("concentration") %>" name="concentration"></td>
                       
                    <td><input type="submit" value="Update"></td>
                </form>


                <form action="degree.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getString("degree_name") %>" name="degree_name">
                    <input type="hidden" value="<%= rs.getString("type") %>" name="type">
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