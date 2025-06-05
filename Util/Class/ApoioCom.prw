#include 'totvs.ch'
#include "FWMVCDef.ch"
#include "Fileio.ch"
#include "msole.ch"
#Include 'rwmake.ch'

/*/{Protheus.doc} ApoioCom
Classe para retornar calculo de impostos

@type Classe
@author Tiago Maniero
@since 25/03/2020
/*/
CLASS ApoioCom
    data cCodigo
    data nQuant
    data nPrcUnit
    data nDesconto
    data nTotal
    data cFornece
    data cTpForn
    data cLoja
    data cTipo
    data cTipoNF
    data nAliquota
    data nBase
    data nValor
    data cTes


    METHOD NewApoioCom() CONSTRUCTOR
    METHOD iniImp()
    METHOD addImp()
    METHOD retImpItem()
    METHOD retImpTot() 

    METHOD getCodigo()
    METHOD setCodigo()
    METHOD getQuant()
    METHOD setQuant()
    METHOD getPrcUnit()
    METHOD setPrcUnit()
    METHOD getDesconto()
    METHOD setDesconto()
    METHOD getTotal()
    METHOD setTotal()
    METHOD getFornece()
    METHOD setFornece()
    METHOD getLoja()
    METHOD setLoja()
    METHOD getTipo()
    METHOD setTipo()
    METHOD getTipoNF()
    METHOD setTipoNF()
    METHOD getAliquota()
    METHOD setAliquota()
    METHOD getBase()
    METHOD setBase()
    METHOD getValor()
    METHOD setValor()
    METHOD getTpForn()
    METHOD setTpForn()
    METHOD getTes()
    METHOD setTes()
    METHOD getValNF()
    METHOD setValNF()



ENDCLASS


/*
Método construtor
*/
METHOD NewApoioCom() class ApoioCom

Return


/*
Getters e Setters
*/
METHOD getCodigo() class ApoioCom
return ::cCodigo


METHOD setCodigo(cCodigo) class ApoioCom
	::cCodigo := cCodigo
return


METHOD getQuant() class ApoioCom
return ::nQuant


METHOD setQuant(nQuant) class ApoioCom
	::nQuant := nQuant
return


METHOD getPrcUnit() class ApoioCom
return ::nPrcUnit


METHOD setPrcUnit(nPrcUnit) class ApoioCom
	::nPrcUnit := nPrcUnit
return


METHOD getDesconto() class ApoioCom
return ::nDesconto


METHOD setDesconto(nDesconto) class ApoioCom
	::nDesconto := nDesconto
return


METHOD getTotal() class ApoioCom
return ::nTotal


METHOD setTotal(nTotal) class ApoioCom
	::nTotal := nTotal
return


METHOD getFornece() class ApoioCom
return ::cFornece


METHOD setFornece(cFornece) class ApoioCom
	::cFornece := cFornece
return


METHOD getLoja() class ApoioCom
return ::cLoja


METHOD setLoja(cLoja) class ApoioCom
	::cLoja := cLoja
return


METHOD getTipo() class ApoioCom
return ::cTipo


METHOD setTipo(cTipo) class ApoioCom
    Iif(cTipo == "Fornecedor", cTipo := "F", cTipo := "C")
	::cTipo := cTipo
return


METHOD getTipoNF() class ApoioCom
return ::cTipoNF


METHOD setTipoNF(cTipoNF) class ApoioCom
	::cTipoNF := cTipoNF
return

METHOD getAliquota() class ApoioCom
return ::nAliquota


METHOD setAliquota(nAliquota) class ApoioCom
	::nAliquota := nAliquota
return


METHOD getBase() class ApoioCom
return ::nBase


METHOD setBase(nBase) class ApoioCom
	::nBase := nBase
return


METHOD getValor() class ApoioCom
return ::nValor


METHOD setValor(nValor) class ApoioCom
	::nValor := nValor
return


METHOD getTpForn() class ApoioCom
return ::cTpForn


METHOD setTpForn(cTpForn) class ApoioCom
	::cTpForn := cTpForn
return


METHOD getTes() class ApoioCom
return ::cTes


METHOD setTes(cTes) class ApoioCom
	::cTes := cTes
return


METHOD getValNF() class ApoioCom
return ::nValNF


METHOD setValNF(nValNF) class ApoioCom
    ::nValNF := nValNF
return 



/*
Método que inicia o calculo de impostos
*/
METHOD iniImp(cFornece,cLoja,cTipo,cTipoNF,cTpForn) class ApoioCom

    ::setLoja(cLoja)
    ::setTipo(cTipo)
    ::setTipoNF(cTipoNF)
    ::setFornece(cFornece)
    ::setTpForn(cTpForn)

    MaFisSave()
	MaFisEnd()

    MaFisIni(::cFornece,;                         // 1-Codigo Cliente/Fornecedor
            ::cLoja,;                             // 2-Loja do Cliente/Fornecedor
            ::cTipo,;                             // 3-C:Cliente , F:Fornecedor
            ::cTipoNF,;                           // 4-Tipo da NF
            ::cTpForn,;                             // 5-Tipo do Cliente/Fornecedor
            MaFisRelImp("",{"SF1","SD1"}),;       // 6-Relacao de Impostos que suportados no arquivo
            ,;                                    // 7-Tipo de complemento
            ,;                                    // 8-Permite Incluir Impostos no Rodape .T./.F.
            "SB1",;                               // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
            "MATA121")                            // 10-Nome da rotina que esta utilizando a funcao
                           



Return


/*
Método para adicionar itens
*/
METHOD addImp(cCodigo,cTes,nQuant,nPrcUnit,nDesconto,nTotal) class ApoioCom

    ::setCodigo(cCodigo)  
    ::setTes(cTes)
    ::setQuant(nQuant)
    ::setPrcUnit(nPrcUnit)
    ::setDesconto(nDesconto)
    ::setTotal(nTotal)


   MaFisAdd(      ::cCodigo,;            // 1-Codigo do Produto                 ( Obrigatorio )
                        ::cTes,;              // 2-Codigo do TES                     ( Opcional )
                        ::nQuant,;       // 3-Quantidade                     ( Obrigatorio )
                        ::nPrcUnit,;     // 4-Preco Unitario                 ( Obrigatorio )
                        ::nDesconto,;    // 5 desconto
                        0,;              // 6-Numero da NF Original             ( Devolucao/Benef )
                        0,;              // 7-Serie da NF Original             ( Devolucao/Benef )
                        0,;              // 8-RecNo da NF Original no arq SD1/SD2
                        0,;              // 9-Valor do Frete do Item         ( Opcional )
                        0,;              // 10-Valor da Despesa do item         ( Opcional )
                        0,;              // 11-Valor do Seguro do item         ( Opcional )
                        0,;              // 12-Valor do Frete Autonomo         ( Opcional )
                        ::nTotal,;       // 13-Valor da Mercadoria             ( Obrigatorio )
                        0,;              // 14-Valor da Embalagem             ( Opcional )
                        0,;              // 15-RecNo do SB1
                        0)               // 16-RecNo do SF4
  
Return


/*
Método para retornar totais dos itens
*/
METHOD retImpItem(nItem,cImp) class ApoioCom
    
    ::setAliquota(MaFisRet(nItem,"IT_ALIQ"+cImp))
    ::setBase(MaFisRet(nItem,"IT_BASE"+cImp))
    ::setValor(MaFisRet(nItem,"IT_VAL"+cImp))
    

Return


/*
Método que retorna Imposto total NF
*/
METHOD retImpTot(cImp) class ApoioCom


Return (MaFisRet(,"NF_"+cImp))
