using Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public class DalTableUsers
    {
        public DalTableUsers()
        {

        }

        /// <summary>
        /// get next no
        /// </summary>
        /// <returns></returns>
        public int GenNextNo()
        {
            string sql = "select nextval('users_no_seq');";
            return int.Parse(SqlHelper.ExecuteScalar(sql).ToString());
        }

        /// <summary>
        /// insert user info
        /// </summary>
        /// <param name="user"></param>
        /// <param name="no"></param>
        /// <returns></returns>
        public bool InsertUserInfo(int no, UserInfo user)
        {
            string sql = "insert into users (no, userid,username,userpwd,busarray,selectbusid,address,accesstoken) values (@no,@userid,@username,@userpwd,@busarray,@selectbusid,@address,@accesstoken)";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@no", no.ToString());
            dict.Add("@userid", user.userid);
            dict.Add("@username", user.username);
            dict.Add("@userpwd", user.userpwd);
            dict.Add("@busarray", user.busarray);
            dict.Add("@selectbusid", user.selectbusid);
            dict.Add("@address", user.address);
            dict.Add("@accesstoken", user.accesstoken);
            int count = SqlHelper.ExecuteNonQuery(sql, dict);
            if (count > 0)
            {
                return true;
            }
            else
            {
                return false;
            }

        }

        /// <summary>
        /// is agency exist
        /// </summary>
        /// <param name="agencyID"></param>
        /// <returns></returns>
        public bool IsUserExists(string userID)
        {
            string sql = "select count(*) from users where userid=@userid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@userid", userID);

            return (SqlHelper.IsExists(sql, dict));
        }

        public bool checkIfExistInBoth(string userID)
        {
            string sql = "select count(*) from users where userid=@userid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@userid", userID);


            string sql2 = "select count(*) from drivers where driverid=@userid";
            Dictionary<string, string> dict2 = new Dictionary<string, string>();
            dict2.Add("@userid", userID);

            return (SqlHelper.IsExists(sql, dict) || SqlHelper.IsExists(sql2, dict2));
        }

        public string GetAccessToken(string userID, string pwd)
        {
            //string sql = "select count(*) from users where userid=@userid and userpwd=@userpwd";
            //Dictionary<string, string> dict = new Dictionary<string, string>();
            //dict.Add("@userid", userID);
            //dict.Add("@userpwd", pwd);
            //return SqlHelper.IsExists(sql, dict);
            string sql = "select accesstoken from users where userid=@userid and userpwd=@userpwd";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@userid", userID);
            dict.Add("@userpwd", pwd);
            Object result = SqlHelper.ExecuteScalar(sql, dict);
            if (result == null)
                return null;
            else
                return result.ToString();
            
        }

        public UserInfo GetuserInfo(string userID)
        {
            string sql = "select userid,username,busarray,selectbusid,address,accesstoken from users where userid=@userid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@userid", userID);
            DataTable tb_data = SqlHelper.GetDataTable(sql, dict);
            UserInfo userInfo = null;
            if (tb_data != null && tb_data.Rows.Count > 0)
            {
                userInfo = new UserInfo();
                userInfo.userid = tb_data.Rows[0]["userid"].ToString();
                userInfo.username = tb_data.Rows[0]["username"].ToString();
                userInfo.busarray = tb_data.Rows[0]["busarray"].ToString();
                userInfo.selectbusid = tb_data.Rows[0]["selectbusid"].ToString();
                userInfo.address = tb_data.Rows[0]["address"].ToString();
                userInfo.accesstoken = tb_data.Rows[0]["accesstoken"].ToString();
                userInfo.role = "parent";
            }
            return userInfo;
        }

        /// <summary>
        /// get all agency info
        /// </summary>
        /// <returns></returns>
        public DataTable GetAllUsers()
        {
            string sql = "select * from users";
            DataTable tb_data = SqlHelper.GetDataTable(sql);
            return tb_data;
        }

        public bool verifyUserID(string userid, string accesstoken)
        {
            string sql = "select count(*) from users where userid=@userid and accesstoken=@accesstoken";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@userid", userid);
            dict.Add("@accesstoken", accesstoken);
            return SqlHelper.IsExists(sql, dict);
        }

        public int updateBusArray(string userid,string busarray)
        {
            string sql = "update users set busarray=@busarray where userid=@userid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@userid", userid);
            dict.Add("@busarray", busarray);
            int rows = SqlHelper.ExecuteNonQuery(sql, dict);
            return rows;
        }

        public int updateSelectBusID(string userid, string selectbusid)
        {
            string sql = "update users set selectbusid=@selectbusid where userid=@userid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@userid", userid);
            dict.Add("@selectbusid", selectbusid);
            int rows = SqlHelper.ExecuteNonQuery(sql, dict);
            return rows;
        }

    }
}
