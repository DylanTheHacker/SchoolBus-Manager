using Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public class DalTableDrivers
    {
        /// <summary>
        /// get next no
        /// </summary>
        /// <returns></returns>
        public int GenNextNo()
        {
            string sql = "select nextval('drivers_no_seq');";
            return int.Parse(SqlHelper.ExecuteScalar(sql).ToString());
        }

        /// <summary>
        /// insert user info
        /// </summary>
        /// <param name="user"></param>
        /// <param name="no"></param>
        /// <returns></returns>
        public bool InsertDriverInfo(int no, DriverModel driverInfo)
        {
            string sql = "insert into drivers (no, driverid,drivername,driverpwd,address,accesstoken) values (@no,@driverid,@drivername,@driverpwd,@address,@accesstoken)";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@no", no.ToString());
            dict.Add("@driverid", driverInfo.driverid);
            dict.Add("@drivername", driverInfo.drivername);
            dict.Add("@driverpwd", driverInfo.driverpwd);
            dict.Add("@address", driverInfo.address);
            dict.Add("@accesstoken", driverInfo.accesstoken);
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
        public bool IsDriverExists(string driverId)
        {
            string sql = "select count(*) from drivers where driverid=@driverid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@driverid", driverId);

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

        public string GetAccessToken(string driverID, string pwd)
        {
            string sql = "select accesstoken from drivers where driverid=@driverid and driverpwd=@driverpwd";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@driverid", driverID);
            dict.Add("@driverpwd", pwd);
            var result = SqlHelper.ExecuteScalar(sql, dict);
            if (result == null)
                return null;
            else
                return result.ToString();
        }

        public DriverModel GetDriverInfo(string driverID, string pwd)
        {
            //string sql = "select drivername busid from busarray,selectbusid,address from users where userid=@userid and userpwd=@userpwd";
            string sql = "select drivername,address from drivers where driverid=@driverid and driverpwd=@driverpwd";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@driverid", driverID);
            dict.Add("@driverpwd", pwd);
            DataTable tb_data = SqlHelper.GetDataTable(sql, dict);
            DriverModel driverModel = null;
            if (tb_data != null && tb_data.Rows.Count > 0)
            {
                driverModel = new DriverModel();
                driverModel.driverid = driverID;
                driverModel.drivername = tb_data.Rows[0]["drivername"].ToString();
                driverModel.address = tb_data.Rows[0]["address"].ToString();                  
            }
            return driverModel;
        }

        /// <summary>
        /// get all agency info
        /// </summary>
        /// <returns></returns>
        public DataTable GetAllDrivers()
        {
            string sql = "select * from drivers";
            DataTable tb_data = SqlHelper.GetDataTable(sql);
            return tb_data;
        }

        public bool verifyDriverID(string driverid, string accesstoken)
        {
            string sql = "select count(*) from drivers where driverid=@driverid and accesstoken=@accesstoken";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@driverid", driverid);
            dict.Add("@accesstoken", accesstoken);
            return SqlHelper.IsExists(sql, dict);
        }
    }

}
