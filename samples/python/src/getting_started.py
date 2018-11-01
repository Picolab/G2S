import time

import json
import logging
from typing import Optional

import requests

import string
import random
import ctypes
import asyncio

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

_host = "http://172.31.182.113:8080"
# dids
agency = "PFR1KHahcYRtoJJGSAQYBJ"
gov   = ""
faber = ""
acme  = ""
thrift= ""


async def run():
    logger.info("Getting started -> started")
    logger.info("\"Agency\" -> Create gov, faber, acme, thrift and alice")

    gov   = event_send(agency,"agency","CREATE",{"name":"gov"    })[0]["options"]["pico"]["eci"]
    faber = event_send(agency,"agency","CREATE",{"name":"faber"  })[0]["options"]["pico"]["eci"]
    acme  = event_send(agency,"agency","CREATE",{"name":"acme"   })[0]["options"]["pico"]["eci"]
    thrift= event_send(agency,"agency","CREATE",{"name":"thrift" })[0]["options"]["pico"]["eci"]
    alice = event_send(agency,"agency","CREATE",{"name":"alice"  })[0]["options"]["pico"]["eci"]

    #input("Agents have been created, feel free to check, Press Enter to continue...")

    logger.info("\ngov:{} \n faber:{} \n acme:{} \n thrift:{}\n alice:{}\n".format(gov,faber,acme,thrift,alice))
    
    logger.info("\"Sovrin Steward\" -> Create and store in Wallet DID from seed")

    steward_did = event_send(gov,"agent","create_did",{"seed":"000000000000000000000000Steward1","meta_data":"steward_did"})[0]["options"]["didVerkey"][0]# this generates the same keys used in the genisis file 
    #input("Steward did generated, Press Enter to continue...")
    
    logger.info("==============================")
    logger.info("=== Subscriptions for Verinym ==")
    logger.info("------------------------------")

    faberGovSid  = subscription(gov, faber ,"Faber" ,"Gov")
    acmeGovSid   = subscription(gov, acme  ,"Acme"  ,"Gov")
    thriftGovSid = subscription(gov, thrift,"Thrift","Gov")
    
    logger.info("==============================")
    logger.info("=== Getting Trust Anchor permissions for Faber, Acme, Thrift and Government using steward did ==")
    logger.info("------------------------------")

    logger.info("==============================")
    logger.info("== Creating Government Verinym ==")
    logger.info("------------------------------")

    govDidVerkey = event_send(gov,"agent","create_did",{"meta_data":"TRUST_ANCHOR"})[0]["options"]["didVerkey"]
    #logger.info(govDidVerkey)
    event_send(gov,"agent","nym",{"signing_did":steward_did,"anchoring_did"       :govDidVerkey[0],
                                                            "anchoring_did_verkey":govDidVerkey[1],
                                                            "alias"               :"Gov",
                                                            "role":"TRUST_ANCHOR"}) # bootstrap gov with trust anchor did.
    #input("Press Enter to continue...")

    logger.info("==============================")
    logger.info("== Creating Faber Verinym  ==")
    logger.info("------------------------------")
    
    # must use steward did, 'TRUST_ANCHOR cannot add TRUST_ANCHOR'
    faberDidVerkey = get_verinym(gov,faber,"TRUST_ANCHOR","Faber",steward_did,faberGovSid)
    #input("Press Enter to continue...")

    logger.info("==============================")
    logger.info("== Creating Acme Verinym  ==")
    logger.info("------------------------------")

    acmDidVerkey = get_verinym(gov,acme,"TRUST_ANCHOR","Acme",steward_did,acmeGovSid)

    logger.info("==============================")
    logger.info("== Creating Thrift Verinym  ==")
    logger.info("------------------------------")

    thriftDidVerkey = get_verinym(gov,thrift,"TRUST_ANCHOR","Faber",steward_did,thriftGovSid)

    logger.info("==============================")
    logger.info("=== Credential definitions ==")
    logger.info("------------------------------")

    logger.info("\"Government\" -> Create \"Job-Certificate\" Schema")
    
    JobCertificateSchemaId = event_send(gov,"agent","create_schema",{"issuer_did":govDidVerkey[0],
                   "name":"Job-Certificate",
                   "version":"0.2",
                   "attrNames":["first_name", "last_name", "salary", "employee_status","experience"]})[0]["options"]["result"]["txnMetadata"]["txnId"]
    logger.info(JobCertificateSchemaId)

    TranscriptSchemaId = event_send(gov,"agent","create_schema",{"issuer_did":govDidVerkey[0],
                   "name":"Transcript",
                   "version":"1.2",
                   "attrNames":["first_name", "last_name", "degree", "status","year","average","ssn"]})[0]["options"]["result"]["txnMetadata"]["txnId"]

    logger.info("==============================")
    logger.info("=== Faber Credential Definition ==")
    logger.info("------------------------------")

    logger.info("\"Faber\" -> Create, store and anchor\"Faber Transcript\" Credential Definition")
    transcriptCredDefId = event_send(faber ,"agent","create_cred_def",{   
                    "schema_issuer_did":govDidVerkey[0],
                    "schema_id":TranscriptSchemaId,
                    "issueing_did":faberDidVerkey[0],
                    "tag":"TAG1" } 
                    ) [0]["options"]["result"]["txnMetadata"]["txnId"]
    logger.info(transcriptCredDefId)
    input("-- faber created cred_def --Press Enter to continue...")

    logger.info("==============================")
    logger.info("=== Acme Credential Definition ==")
    logger.info("------------------------------")

    logger.info("\"Acme\" -> Create, store and anchor \"Acme Job-Certificate\" Credential Definition")
    jobCertificateCredDefId = event_send(acme ,"agent","create_cred_def",{   
                    "schema_issuer_did":govDidVerkey[0],
                    "schema_id":JobCertificateSchemaId,
                    "issueing_did":acmDidVerkey[0],
                    "tag":"TAG1" } 
                    ) [0]["options"]["result"]["txnMetadata"]["txnId"]

    logger.info("==============================")
    logger.info("=== Getting Transcript with Faber ==")
    logger.info("==============================")
    logger.info("== Alice Faber - Onboarding (subscription) ==")
    logger.info("------------------------------")
    
    aliceFaberSid = subscription(faber, alice ,"Alice" ,"Faber")

    aliceDidVerkey = event_send(gov,"agent","create_did",{"meta_data":"faber_cred"})[0]["options"]["didVerkey"] # did for get_cred_def_request

    logger.info("==============================")
    logger.info("== Getting Transcript with Faber - Getting Transcript Credential ==")
    logger.info("------------------------------")

    logger.info("\"Faber\" -> Create and Send\"Transcript\" Credential Offer for Alice")
    #offer = sky_cloud_API(rx,"G2S.agent","credentialOffer",{"cred_def_id":jobCertificateCredDefId})

    offerId = event_send(faber,"agent","send_credential_offer",{"sid":aliceFaberSid})[0]["options"]["id"]

    logger.info("\"Alice\" -> Get \"Faber Transcript\" Credential Definition from Ledger")
    logger.info("\"Alice\" -> Create \"Transcript\" Credential Request for Faber")
    logger.info("\"Alice\" -> Send   \"Transcript\" Credential Request to Faber")

    requestId = event_send(alice,"agent","accept_credential_offer_with_request",{   "sid"         :aliceFaberSid, 
                                                                                    "offerId"     :offerId,
                                                                                    "submitterDid":faberDidVerkey[0],
                                                                                    "credDefId"   :transcriptCredDefId,
                                                                                    "proverDid"   :aliceDidVerkey[0],
                                                                                        })[0]["options"]["id"]


    logger.info("\"Faber\" -> Create \"Transcript\" Credential for Alice")
    event_send(faber,"agent","issue_credential_from_request",{  "sid"        : aliceFaberSid,
                                                                "requestId"  : requestId ,
                                                                "credAttributes": {
                                                                                    "first_name": "Alice",
                                                                                    "last_name": "Garcia",
                                                                                    "degree": "Bachelor of Science, Marketing",
                                                                                    "status": "graduated",
                                                                                    "ssn": "123-45-6789",
                                                                                    "year": "2015",
                                                                                    "average": "5"
                                                                                } })
    
    #transcript_cred_values = {
    #    "first_name": {"raw": "Alice", "encoded": "1139481716457488690172217916278103335"},
    #    "last_name": {"raw": "Garcia", "encoded": "5321642780241790123587902456789123452"},
    #    "degree": {"raw": "Bachelor of Science, Marketing", "encoded": "12434523576212321"},
    #    "status": {"raw": "graduated", "encoded": "2213454313412354"},
    #    "ssn": {"raw": "123-45-6789", "encoded": "3124141231422543541"},
    #    "year": {"raw": "2015", "encoded": "2015"},
    #    "average": {"raw": "5", "encoded": "5"}
    #}
    
    # await anoncreds.issuer_create_credential(faber_wallet[0], transcript_cred_offer_json, transcript_cred_request_json, transcript_cred_values, None, None)

    logger.info("\"Faber\" -> Send \"Transcript\" Credential to Alice")

    logger.info("\"Alice\" -> Store \"Transcript\" Credential from Faber")

    # await anoncreds.prover_store_credential(alice_wallet[0], None, transcript_cred_request_metadata_json, transcript_cred_json, faber_transcript_cred_def, None)

    logger.info("==============================")
    logger.info("=== Apply for the job with Acme ==")
    logger.info("==============================")
    logger.info("== Apply for the job with Acme - Onboarding (subscription) ==")
    logger.info("------------------------------")

    aliceAcmeSid = subscription(acme, alice ,"Alice" ,"Acme")

    logger.info("==============================")
    logger.info("== Apply for the job with Acme - Transcript proving ==")
    logger.info("------------------------------")

    logger.info("\"Acme\" -> Create \"Job-Application\" Proof Request")
    '''
    The flow is now (python):
        -`prover_search_credentials_for_proof_req` which returns a search handle (passing the proof req. json).
        -`prover_fetch_credentials_for_proof_req` passing the search handle and the number of hits you want, and the 
            'referent' (ie "ssn_referent") from your proof request. You can do this multiple times if your referents 
            were in different credentials. But if everything is in one credential, then you only have to do this once (not 100% on that part).
        - and then close the search handle with `prover_close_credentials_search_for_proof_req`

        This test shows the flow in the rust code:
        https://github.com/hyperledger/indy-sdk/blob/8157226e34ac06913fdfaa9bcee42c7573bff41a/libindy/tests/anoncreds.rs#L2482
    
    
    job_application_proof_request_json = {
        'nonce': '1432422343242122312411212',
        'name': 'Job-Application',
        'version': '0.1',
        'requested_attributes': {
            'attr1_referent': {
                'name': 'first_name'
            },
            'attr2_referent': {
                'name': 'last_name'
            },
            'attr3_referent': {
                'name': 'degree',
                'restrictions': [{'cred_def_id': faber_transcript_cred_def_id}]
            },
            'attr4_referent': {
                'name': 'status',
                'restrictions': [{'cred_def_id': faber_transcript_cred_def_id}]
            },
            'attr5_referent': {
                'name': 'ssn',
                'restrictions': [{'cred_def_id': faber_transcript_cred_def_id}]
            },
            'attr6_referent': {
                'name': 'phone_number'
            }
        },
        'requested_predicates': {
            'predicate1_referent': {
                'name': 'average',
                'p_type': '>=',
                'p_value': 4,
                'restrictions': [{'cred_def_id': faber_transcript_cred_def_id}]
            }
        }
    }

    logger.info("\"Acme\" -> Send \"Job-Application\" Proof Request to Alice")

    logger.info("\"Alice\" -> Get credentials for \"Job-Application\" Proof Request")

    search_for_job_application_proof_request = \
        await anoncreds.prover_search_credentials_for_proof_req(alice_wallet[0],
                                                                job_application_proof_request_json, None)

    cred_for_attr1 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr1_referent')
    cred_for_attr2 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr2_referent')
    cred_for_attr3 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr3_referent')
    cred_for_attr4 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr4_referent')
    cred_for_attr5 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr5_referent')
    cred_for_predicate1 = \
        await get_credential_for_referent(search_for_job_application_proof_request, 'predicate1_referent')

    await anoncreds.prover_close_credentials_search_for_proof_req(search_for_job_application_proof_request)

    creds_for_job_application_proof = {cred_for_attr1['referent']: cred_for_attr1,
                                       cred_for_attr2['referent']: cred_for_attr2,
                                       cred_for_attr3['referent']: cred_for_attr3,
                                       cred_for_attr4['referent']: cred_for_attr4,
                                       cred_for_attr5['referent']: cred_for_attr5,
                                       cred_for_predicate1['referent']: cred_for_predicate1}

    schemas_json, cred_defs_json, revoc_states_json = \
        await prover_get_entities_from_ledger(pool_handle, alice_faber_did, creds_for_job_application_proof, 'Alice')

    logger.info("\"Alice\" -> Create \"Job-Application\" Proof")
    job_application_requested_creds_json = json.dumps({
        'self_attested_attributes': {
            'attr1_referent': 'Alice',
            'attr2_referent': 'Garcia',
            'attr6_referent': '123-45-6789'
        },
        'requested_attributes': {
            'attr3_referent': {'cred_id': cred_for_attr3['referent'], 'revealed': True},
            'attr4_referent': {'cred_id': cred_for_attr4['referent'], 'revealed': True},
            'attr5_referent': {'cred_id': cred_for_attr5['referent'], 'revealed': True},
        },
        'requested_predicates': {'predicate1_referent': {'cred_id': cred_for_predicate1['referent']}}
    })

    job_application_proof_json = \
        await anoncreds.prover_create_proof(alice_wallet[0], job_application_proof_request_json,
                                            job_application_requested_creds_json, alice_master_secret_id,
                                            schemas_json, cred_defs_json, revoc_states_json)

    logger.info("\"Alice\" -> Send \"Job-Application\" Proof to Acme")

    decrypted_job_application_proof = json.loads(job_application_proof_json)

    schemas_json, cred_defs_json, revoc_ref_defs_json, revoc_regs_json = \
        await verifier_get_entities_from_ledger(pool_handle, acme_did,
                                                decrypted_job_application_proof['identifiers'], 'Acme')

    logger.info("\"Acme\" -> Verify \"Job-Application\" Proof from Alice")
    assert 'Bachelor of Science, Marketing' == \
           decrypted_job_application_proof['requested_proof']['revealed_attrs']['attr3_referent']['raw']
    assert 'graduated' == \
           decrypted_job_application_proof['requested_proof']['revealed_attrs']['attr4_referent']['raw']
    assert '123-45-6789' == \
           decrypted_job_application_proof['requested_proof']['revealed_attrs']['attr5_referent']['raw']

    assert 'Alice' == decrypted_job_application_proof['requested_proof']['self_attested_attrs']['attr1_referent']
    assert 'Garcia' == decrypted_job_application_proof['requested_proof']['self_attested_attrs']['attr2_referent']
    assert '123-45-6789' == decrypted_job_application_proof['requested_proof']['self_attested_attrs']['attr6_referent']

    assert await anoncreds.verifier_verify_proof(job_application_proof_request_json,
                                                 job_application_proof_json,
                                                 schemas_json, cred_defs_json, revoc_ref_defs_json, revoc_regs_json)

    logger.info("==============================")
    logger.info("== Apply for the job with Acme - Getting Job-Certificate Credential ==")
    logger.info("------------------------------")

    logger.info("\"Acme\" -> Create \"Job-Certificate\" Credential Offer for Alice")
    job_certificate_cred_offer_json = \
        await anoncreds.issuer_create_credential_offer(acme_wallet[0], acme_job_certificate_cred_def_id)

    logger.info("\"Acme\" -> Send \"Job-Certificate\" Credential Offer to Alice")

    authdecrypted_job_certificate_cred_offer = json.loads(job_certificate_cred_offer_json)
    logger.info("\"Alice\" -> Get \"Acme Job-Certificate\" Credential Definition from Ledger")

    # await did.create_and_store_my_did(alice_wallet[0], "{}") # did for cred

    (_, acme_job_certificate_cred_def) = \
        await get_cred_def(pool_handle, alice_acme_did, authdecrypted_job_certificate_cred_offer['cred_def_id'])

    logger.info("\"Alice\" -> Create and store in Wallet \"Job-Certificate\" Credential Request for Acme")
    (job_certificate_cred_request_json, job_certificate_cred_request_metadata_json) = \
        await anoncreds.prover_create_credential_req(alice_wallet[0], alice_acme_did,
                                                     job_certificate_cred_offer_json,
                                                     acme_job_certificate_cred_def, alice_master_secret_id)

    logger.info("\"Alice\" -> Send \"Job-Certificate\" Credential Request to Acme")

    logger.info("\"Acme\" -> Create \"Job-Certificate\" Credential for Alice")
    alice_job_certificate_cred_values_json = json.dumps({
        "first_name": {"raw": "Alice", "encoded": "245712572474217942457235975012103335"},
        "last_name": {"raw": "Garcia", "encoded": "312643218496194691632153761283356127"},
        "employee_status": {"raw": "Permanent", "encoded": "2143135425425143112321314321"},
        "salary": {"raw": "2400", "encoded": "2400"},
        "experience": {"raw": "10", "encoded": "10"}
    })

    job_certificate_cred_json, _, _ = \
        await anoncreds.issuer_create_credential(acme_wallet[0], job_certificate_cred_offer_json,
                                                 job_certificate_cred_request_json,
                                                 alice_job_certificate_cred_values_json, None, None)

    logger.info("\"Acme\" -> Send \"Job-Certificate\" Credential to Alice")

    logger.info("\"Alice\" -> Store \"Job-Certificate\" Credential")
    await anoncreds.prover_store_credential(alice_wallet[0], None, job_certificate_cred_request_metadata_json,
                                            job_certificate_cred_json,
                                            acme_job_certificate_cred_def_json, None)

    logger.info("==============================")
    logger.info("=== Apply for the loan with Thrift ==")
    logger.info("==============================")
    logger.info("== Apply for the loan with Thrift - Onboarding ==")
    logger.info("------------------------------")
    
    ( alice_thrift_did, _ ) = await did.create_and_store_my_did(alice_wallet[0], "{}")

    logger.info("==============================")
    logger.info("== Apply for the loan with Thrift - Job-Certificate proving  ==")
    logger.info("------------------------------")

    logger.info("\"Thrift\" -> Create \"Loan-Application-Basic\" Proof Request")
    apply_loan_proof_request_json = json.dumps({
        'nonce': '123432421212',
        'name': 'Loan-Application-Basic',
        'version': '0.1',
        'requested_attributes': {
            'attr1_referent': {
                'name': 'employee_status',
                'restrictions': [{'cred_def_id': acme_job_certificate_cred_def_id}]
            }
        },
        'requested_predicates': {
            'predicate1_referent': {
                'name': 'salary',
                'p_type': '>=',
                'p_value': 2000,
                'restrictions': [{'cred_def_id': acme_job_certificate_cred_def_id}]
            },
            'predicate2_referent': {
                'name': 'experience',
                'p_type': '>=',
                'p_value': 1,
                'restrictions': [{'cred_def_id': acme_job_certificate_cred_def_id}]
            }
        }
    })

    logger.info("\"Thrift\" -> Send \"Loan-Application-Basic\" Proof Request to Alice")

    logger.info("\"Alice\" -> Get credentials for \"Loan-Application-Basic\" Proof Request")

    search_for_apply_loan_proof_request = \
        await anoncreds.prover_search_credentials_for_proof_req(alice_wallet[0],
                                                                apply_loan_proof_request_json, None)

    cred_for_attr1 = await get_credential_for_referent(search_for_apply_loan_proof_request, 'attr1_referent')
    cred_for_predicate1 = await get_credential_for_referent(search_for_apply_loan_proof_request, 'predicate1_referent')
    cred_for_predicate2 = await get_credential_for_referent(search_for_apply_loan_proof_request, 'predicate2_referent')

    await anoncreds.prover_close_credentials_search_for_proof_req(search_for_apply_loan_proof_request)

    creds_for_apply_loan_proof = {cred_for_attr1['referent']: cred_for_attr1,
                                  cred_for_predicate1['referent']: cred_for_predicate1,
                                  cred_for_predicate2['referent']: cred_for_predicate2}

    schemas_json, cred_defs_json, revoc_states_json = \
        await prover_get_entities_from_ledger(pool_handle, alice_thrift_did, creds_for_apply_loan_proof, 'Alice')

    logger.info("\"Alice\" -> Create \"Loan-Application-Basic\" Proof")
    apply_loan_requested_creds_json = json.dumps({
        'self_attested_attributes': {},
        'requested_attributes': {
            'attr1_referent': {'cred_id': cred_for_attr1['referent'], 'revealed': True}
        },
        'requested_predicates': {
            'predicate1_referent': {'cred_id': cred_for_predicate1['referent']},
            'predicate2_referent': {'cred_id': cred_for_predicate2['referent']}
        }
    })
    alice_apply_loan_proof_json = \
        await anoncreds.prover_create_proof(alice_wallet[0], apply_loan_proof_request_json,
                                            apply_loan_requested_creds_json, alice_master_secret_id, schemas_json,
                                            cred_defs_json, revoc_states_json)

    logger.info("\"Alice\" -> Send \"Loan-Application-Basic\" Proof to Thrift")

    authdecrypted_alice_apply_loan_proof = json.loads(alice_apply_loan_proof_json)
    logger.info("\"Thrift\" -> Get Schemas, Credential Definitions and Revocation Registries from Ledger"
                " required for Proof verifying")

    schemas_json, cred_defs_json, revoc_defs_json, revoc_regs_json = \
        await verifier_get_entities_from_ledger(pool_handle, thrift_did,
                                                authdecrypted_alice_apply_loan_proof['identifiers'1], 'Thrift')

    logger.info("\"Thrift\" -> Verify \"Loan-Application-Basic\" Proof from Alice")
    assert 'Permanent' == \
           authdecrypted_alice_apply_loan_proof['requested_proof']['revealed_attrs']['attr1_referent']['raw']

    assert await anoncreds.verifier_verify_proof(apply_loan_proof_request_json,
                                                 alice_apply_loan_proof_json,
                                                 schemas_json, cred_defs_json, revoc_defs_json, revoc_regs_json)

    logger.info("==============================")

    logger.info("==============================")
    logger.info("== Apply for the loan with Thrift - Transcript and Job-Certificate proving  ==")
    logger.info("------------------------------")

    logger.info("\"Thrift\" -> Create \"Loan-Application-KYC\" Proof Request")
    apply_loan_kyc_proof_request_json = json.dumps({
        'nonce': '123432421212',
        'name': 'Loan-Application-KYC',
        'version': '0.1',
        'requested_attributes': {
            'attr1_referent': {'name': 'first_name'},
            'attr2_referent': {'name': 'last_name'},
            'attr3_referent': {'name': 'ssn'}
        },
        'requested_predicates': {}
    })

    logger.info("\"Thrift\" -> Send \"Loan-Application-KYC\" Proof Request to Alice")

    logger.info("\"Alice\" -> Get credentials for \"Loan-Application-KYC\" Proof Request")

    search_for_apply_loan_kyc_proof_request = \
        await anoncreds.prover_search_credentials_for_proof_req(alice_wallet[0],
                                                                apply_loan_kyc_proof_request_json, None)

    cred_for_attr1 = await get_credential_for_referent(search_for_apply_loan_kyc_proof_request, 'attr1_referent')
    cred_for_attr2 = await get_credential_for_referent(search_for_apply_loan_kyc_proof_request, 'attr2_referent')
    cred_for_attr3 = await get_credential_for_referent(search_for_apply_loan_kyc_proof_request, 'attr3_referent')

    await anoncreds.prover_close_credentials_search_for_proof_req(search_for_apply_loan_kyc_proof_request)

    creds_for_apply_loan_kyc_proof = {cred_for_attr1['referent']: cred_for_attr1,
                                      cred_for_attr2['referent']: cred_for_attr2,
                                      cred_for_attr3['referent']: cred_for_attr3}

    schemas_json, cred_defs_json, revoc_states_json = \
        await prover_get_entities_from_ledger(pool_handle, alice_thrift_did, creds_for_apply_loan_kyc_proof, 'Alice')

    logger.info("\"Alice\" -> Create \"Loan-Application-KYC\" Proof")

    apply_loan_kyc_requested_creds_json = json.dumps({
        'self_attested_attributes': {},
        'requested_attributes': {
            'attr1_referent': {'cred_id': cred_for_attr1['referent'], 'revealed': True},
            'attr2_referent': {'cred_id': cred_for_attr2['referent'], 'revealed': True},
            'attr3_referent': {'cred_id': cred_for_attr3['referent'], 'revealed': True}
        },
        'requested_predicates': {}
    })

    alice_apply_loan_kyc_proof_json = \
        await anoncreds.prover_create_proof(alice_wallet[0], apply_loan_kyc_proof_request_json,
                                            apply_loan_kyc_requested_creds_json, alice_master_secret_id,
                                            schemas_json, cred_defs_json, revoc_states_json)

    logger.info("\"Alice\" -> Send \"Loan-Application-KYC\" Proof to Thrift")

    authdecrypted_alice_apply_loan_kyc_proof = json.loads(alice_apply_loan_kyc_proof_json)
    logger.info("\"Thrift\" -> Get Schemas, Credential Definitions and Revocation Registries from Ledger"
                " required for Proof verifying")

    schemas_json, cred_defs_json, revoc_defs_json, revoc_regs_json = \
        await verifier_get_entities_from_ledger(pool_handle, thrift_did,
                                                authdecrypted_alice_apply_loan_kyc_proof['identifiers'], 'Thrift')

    logger.info("\"Thrift\" -> Verify \"Loan-Application-KYC\" Proof from Alice")
    assert 'Alice' == \
           authdecrypted_alice_apply_loan_kyc_proof['requested_proof']['revealed_attrs']['attr1_referent']['raw']
    assert 'Garcia' == \
           authdecrypted_alice_apply_loan_kyc_proof['requested_proof']['revealed_attrs']['attr2_referent']['raw']
    assert '123-45-6789' == \
           authdecrypted_alice_apply_loan_kyc_proof['requested_proof']['revealed_attrs']['attr3_referent']['raw']

    assert await anoncreds.verifier_verify_proof(apply_loan_kyc_proof_request_json,
                                                 alice_apply_loan_kyc_proof_json,
                                                 schemas_json, cred_defs_json, revoc_defs_json, revoc_regs_json)

    '''
    logger.info("Remove gov, faber, acme and thrift agents")
    
    event_send(agency,"agency","DELETE",{"name":"gov"    })
    event_send(agency,"agency","DELETE",{"name":"faber"  })
    event_send(agency,"agency","DELETE",{"name":"acme"   })
    event_send(agency,"agency","DELETE",{"name":"thrift" })
    event_send(agency,"agency","DELETE",{"name":"alice"  })

    logger.info("Getting started -> done")

def subscription(rx,tx,Rx_role,Tx_role): #onboard
    rxWellknown = sky_cloud_API(rx,"io.picolabs.subscription","wellKnown_Rx",{})["id"]# get wellknown did.
    event_send(tx,"agent","connect" ,{"destination_did":rxWellknown ,"Rx_role":Rx_role, "Tx_role":Tx_role }) # create subscription to gov
    return sky_cloud_API(rx,"io.picolabs.subscription","mostRecentSubscription",{})

def get_verinym(anchorer,anchoree,nym_role,alias,signing_did,subscription_id):
    #signing_did = sky_cloud_API(anchorer,"G2S.agent","dids",{"metadata": "steward_did" })[0]["did"]# get signing did
    didVerkey = event_send(anchoree,"agent","create_did",{"meta_data":nym_role})[0]["options"]["didVerkey"] # create did to be anchored
    nymRequestId = event_send(anchoree,"agent","send_nym_request",{"anchoring_did":didVerkey[0],
                                                                   "anchoring_did_verkey":didVerkey[1],
                                                                   "alias":alias,
                                                                   "role":nym_role,
                                                                   "sid":subscription_id} )[0]["options"]["id"] # anchoree request nym from anchorer (send did to gov)
    event_send(anchorer,"agent","accept_nym_request",{"nym_request_id": nymRequestId, "signing_did":signing_did}) # anchorer accept anchoree nym request (anchorer nym transaction with signing_did)
    return didVerkey
def event_send(eci,domain,type,attrs):
    result = requests.post(_host+"/sky/event/"+eci+"/none/"+domain+"/"+type,params=attrs).json()
    if "directives" in result:
        return result["directives"]
    return result

def sky_cloud_API(eci,rid,function,attrs):
    return requests.post(_host+"/sky/cloud/"+eci+"/"+rid+"/"+function,params=attrs).json()

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(run())
    time.sleep(1)  # FIXME waiting for libindy thread complete
