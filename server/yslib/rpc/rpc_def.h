#ifndef _RPC_DEF_H_
#define _RPC_DEF_H_

enum rpc_status_e
{
    RPC_DISCONNECTED = 0,
    RPC_CONNECTING,
    RPC_CONNECTED,
};

enum rpc_connection_type_e
{
    RPC_ACTIVE, 
    RPC_PASSIVE
};

enum rpc_error_e
{
    RPC_STATUS_ERROR,  //! wrong status invoke
    RPC_READ_ERROR,    //! read failed
    RPC_WRITE_ERROR,   //! write failed
    RPC_BEAUDITED      //! connection be audited for some limit
};

enum rpc_close_type_e
{
    RPC_CLOSE = 0,
    RPC_SHUTDOWN,
    RPC_KILL,
};

#endif
