using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using System.Data;

namespace DAL
{
    public class DalTableBus
    {
        public DalTableBus()
        {

        }
        /// <summary>
        /// get next no
        /// </summary>
        /// <returns></returns>
        public int GenNextNo()
        {
            string sql = "select nextval('bus_no_seq');";
            return int.Parse(SqlHelper.ExecuteScalar(sql).ToString());
        }

        /// <summary>
        /// insert bus info
        /// </summary>
        /// <param name="businfo"></param>
        /// <param name="no"></param>
        /// <returns></returns>
        public bool InsertBusInfo(BusInfo busInfo,int no)
        {
            string sql = "insert into bus (no,busid,buspwd,driverid,useridlist,busname) values(@no,@busid,@buspwd,@driverid,@useridlist,@busname)";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@no", no.ToString());
            dict.Add("@busid",busInfo.busid);
            dict.Add("@buspwd", busInfo.buspwd);
            dict.Add("@driverid", busInfo.driverid);
            dict.Add("@useridlist", busInfo.useridlist);
            dict.Add("@busname",busInfo.busname);
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
        /// get all bus info
        /// </summary>
        /// <returns></returns>
        public DataTable getAllBusInfo()
        {
            string sql = "select * from bus order by no asc";
            DataTable tb_data = SqlHelper.GetDataTable(sql);
            return tb_data;
        }

        /// <summary>
        /// get bus info by driverid
        /// </summary>
        /// <param name="driverid"></param>
        /// <returns></returns>
        public DataTable getBusInfoByDriverID(string driverid)
        {
            string sql = "select * from bus where driverid =@driverid order by no asc";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@driverid", driverid);
            DataTable tb_data = SqlHelper.GetDataTable(sql, dict);
            return tb_data;
        }

        /// <summary>
        /// get bus info by busid
        /// </summary>
        /// <param name="driverid"></param>
        /// <returns></returns>
        public DataTable getBusInfoByBusID(string busid)
        {
            string sql = "select * from bus where busid =@busid order by no asc";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@busid", busid);
            DataTable tb_data = SqlHelper.GetDataTable(sql, dict);
            return tb_data;
        }

        /// <summary>
        /// get useridlist by busid
        /// </summary>
        /// <param name="busid"></param>
        /// <returns></returns>
        public string getUserIDListByBusID(string busid)
        {
            string sql = "select useridlist from bus where busid =@busid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@busid", busid);
            var obj = SqlHelper.ExecuteScalar(sql, dict);
            if (obj == null)
                return "";
            return SqlHelper.ExecuteScalar(sql, dict).ToString();
        }

        ///<summary>
        ///Verify password 
        ///</summary>
        /// <param name="busid"></param>
        /// <param name="buspwd"></param>
        /// <returns></returns>
        public bool verifyBusPwd(string busid, string buspwd)
        {
            string sql = "select count(*) from bus where busid=@busid and buspwd=@buspwd";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@busid",busid);
            dict.Add("@buspwd", buspwd);
            return SqlHelper.IsExists(sql,dict);
        }

        ///<summary>
        ///update userid list 
        ///</summary>
        ///<param name="busid"></param>
        /// <param name="useridlist"></param>
        /// <returns></returns>
        public int updateUseridList(string busid,string useridlist)
        {
            string sql = "update bus set useridlist=@useridlist where busid=@busid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@busid",busid);
            dict.Add("@useridlist", useridlist);
            int rows = SqlHelper.ExecuteNonQuery(sql, dict);
            return rows;
        }

        public bool deleteBusInfoByBusID(string busid)
        {
            string sql = "delete from bus where busid=@busid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@busid", busid);
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
        /// is busname exist
        /// </summary>
        /// <param name="busname"></param>
        /// <returns></returns>
        public bool IsBusNameExists(string busname)
        {
            string sql = "select count(*) from bus where busname=@busname";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@busname", busname);

            return (SqlHelper.IsExists(sql, dict));
        }
    }
}
